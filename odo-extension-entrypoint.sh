#!/usr/bin/env bash
###################################################################################
# Copyright (c) 2019 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
###################################################################################

# Define general variables
ODO_EXTENSION_DIR=/codewind-workspace/.extensions/codewind-odo-extension

ROOT=$1
LOCAL_WORKSPACE=$2
PROJECT_ID=$3
COMMAND=$4
CONTAINER_NAME=$5
AUTO_BUILD_ENABLED=$6
LOGNAME=$7
START_MODE=$8
DEBUG_PORT=$9
FORCE_ACTION=${10}
FOLDER_NAME=${11}
DEPLOYMENT_REGISTRY=${12}
COMPONENT_TYPE=${13}

####################
# Hardcode parameters value for testing purpose
ROOT=/codewind-workspace/nodejs-ex
PROJECT_ID=000
FOLDER_NAME=odo-log
COMPONENT_TYPE=nodejs

####################

WORKSPACE=/codewind-workspace
LOG_FOLDER=$WORKSPACE/.logs/$FOLDER_NAME
ODO_BUILD_LOG=$LOG_FOLDER/odo.build.log
ODO_APP_LOG=$LOG_FOLDER/odo.app.log
ODO_DEBUG_LOG=$LOG_FOLDER/odo.debug.log
PROJECT_NAME=$(basename $ROOT)
COMPONENT_NAME=$PROJECT_NAME

echo "*** ODO"
echo "*** PWD = $PWD"
echo "*** ROOT = $ROOT"
echo "*** LOCAL_WORKSPACE = $LOCAL_WORKSPACE"
echo "*** PROJECT_ID = $PROJECT_ID"
echo "*** COMMAND = $COMMAND"
echo "*** CONTAINER_NAME = $CONTAINER_NAME"
echo "*** AUTO_BUILD_ENABLED = $AUTO_BUILD_ENABLED"
echo "*** LOGNAME = $LOGNAME"
echo "*** START_MODE = $START_MODE"
echo "*** DEBUG_PORT = $DEBUG_PORT"
echo "*** FORCE_ACTION = $FORCE_ACTION"
echo "*** LOG_FOLDER = $LOG_FOLDER"
echo "*** DEPLOYMENT_REGISTRY = $DEPLOYMENT_REGISTRY"
echo "*** HOST_OS = $HOST_OS"
echo "*** COMPONENT_TYPE = $COMPONENT_TYPE"

# General setup
source /file-watcher/scripts/constants.sh
set -o pipefail
util=/file-watcher/scripts/util.sh
odo=$ODO_EXTENSION_DIR/scripts/odo-functions.sh
odoUtil=$ODO_EXTENSION_DIR/scripts/odo-util.sh

# Go into the project directory
cd $ROOT

function create() {
    echo "Touching odo build log file: $ODO_BUILD_LOG" |& tee -a $ODO_DEBUG_LOG
	touch $ODO_BUILD_LOG
	echo "Triggering log file event for: $ODO_BUILD_LOG" |& tee -a $ODO_DEBUG_LOG
	$util newLogFileAvailable $PROJECT_ID "build"

	echo -e "\nCreating, building and deploying odo application" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$util updateBuildState $PROJECT_ID $BUILD_STATE_INPROGRESS $BUILD_CREATE_INPROGRESS_MSG
	echo -e "\nStep 1 of 4:" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$odo create $COMPONENT_TYPE $COMPONENT_NAME $ODO_BUILD_LOG $ODO_DEBUG_LOG
	if [ $? -ne 0 ]; then
		$util updateBuildState $PROJECT_ID $BUILD_STATE_FAILED $BUILD_CREATE_FAIL_MSG
		exit 1
	fi
	
	$util updateBuildState $PROJECT_ID $BUILD_STATE_INPROGRESS $BUILD_PUSH_INPROGRESS_MSG
	echo -e "\nStep 2 of 4:" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$odo push $COMPONENT_NAME $ODO_BUILD_LOG $ODO_DEBUG_LOG
	if [ $? -ne 0 ]; then
		$util updateBuildState $PROJECT_ID $BUILD_STATE_FAILED $BUILD_PUSH_FAIL_MSG
		exit 1
	fi

	$util updateBuildState $PROJECT_ID $BUILD_STATE_INPROGRESS $BUILD_URL_INPROGRESS_MSG
	echo -e "\nStep 3 of 4:" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$odo url $COMPONENT_NAME $ODO_BUILD_LOG $ODO_DEBUG_LOG
	if [ $? -ne 0 ]; then
		$util updateBuildState $PROJECT_ID $BUILD_STATE_FAILED $BUILD_URL_FAIL_MSG
		exit 1
	fi

	$util updateBuildState $PROJECT_ID $BUILD_STATE_INPROGRESS $BUILD_PUSH_INPROGRESS_MSG
	echo -e "\nStep 4 of 4:" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$odo push $COMPONENT_NAME $ODO_BUILD_LOG $ODO_DEBUG_LOG
	if [ $? -eq 0 ]; then
		echo -e "\nSuccessfully created, built and deployed odo application\n" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		$util updateBuildState $PROJECT_ID $BUILD_STATE_SUCCESS
	else
		echo -e "\nFailed to create or build or deploy odo application\n" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		$util updateBuildState $PROJECT_ID $BUILD_STATE_FAILED $BUILD_PUSH_FAIL_MSG
		exit 1
	fi

	echo "Touching odo app log file: $ODO_APP_LOG" |& tee -a $ODO_DEBUG_LOG
	touch $ODO_APP_LOG
	echo "Triggering log file event for: $ODO_APP_LOG" |& tee -a $ODO_DEBUG_LOG
	$util newLogFileAvailable $PROJECT_ID "app"

	echo "Starting odo application" |& tee -a $ODO_DEBUG_LOG
	$util updateAppState $PROJECT_ID $APP_STATE_STOPPED
	kubectl logs -f $(kubectl get po -o name --selector=deploymentconfig=$COMPONENT_NAME-app) >> "$ODO_APP_LOG" &
	$util updateAppState $PROJECT_ID $APP_STATE_STARTING
}

function remove() {
	echo -e "\nRemoving odo application" |& tee -a $ODO_DEBUG_LOG
	echo -e "\nStep 1 of 1:" |& tee -a $ODO_DEBUG_LOG
    $odo delete $COMPONENT_NAME |& tee -a $ODO_DEBUG_LOG

	if [ $? -eq 0 ]; then
		echo -e "\nSuccessfully removed odo application\n" |& tee -a $ODO_DEBUG_LOG
	else
		echo -e "\nFailed to remove odo application\n" |& tee -a $ODO_DEBUG_LOG
		exit 1
	fi
}

function update() {
    echo -e "\nUpdating odo application" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$util updateBuildState $PROJECT_ID $BUILD_STATE_INPROGRESS $BUILD_PUSH_INPROGRESS_MSG
	echo -e "\nStep 1 of 1:" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
    $odo push $COMPONENT_NAME $ODO_BUILD_LOG $ODO_DEBUG_LOG

	if [ $? -eq 0 ]; then
		echo -e "\nSuccessfully updated odo application\n" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		$util updateAppState $PROJECT_ID $BUILD_STATE_SUCCESS
	else
		echo -e "\nFailed to update odo application\n" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		$util updateAppState $PROJECT_ID $BUILD_STATE_FAILED $BUILD_PUSH_FAIL_MSG
		exit 1
	fi

	echo "Starting odo application" |& tee -a $ODO_DEBUG_LOG
	$util updateAppState $PROJECT_ID $APP_STATE_STARTING
}

# Create, build, deploy component to the OpenShift cluster
if [ "$COMMAND" == "create" ]; then
	create

# Update, build, deploy component to the OpenShift cluster
elif [ "$COMMAND" == "update" ]; then
	update

# Enable auto build
elif [ "$COMMAND" == "enableautobuild" ]; then
	watch

# Disable auto build
elif [ "$COMMAND" == "disableautobuild" ]; then
	echo "Disabling auto build for odo component: $COMPONENT_NAME"
	kill -9 $(ps aux | grep "odo watch" | head -n 1 | awk '{print $2}')
	if [ $? -eq 0 ]; then
		echo "Successfully disabled odo application"
	else
		echo "Failed to disable odo application"
	fi

# Remove component from the OpenShift cluster
elif [ "$COMMAND" == "remove" ]; then
	remove

# Rebuild and deploy component to the OpenShift cluster
elif [ "$COMMAND" == "rebuild" ]; then
	update
fi


