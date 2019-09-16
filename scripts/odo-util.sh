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

COMMAND=$1
shift 1

function getAppName() {
    APP_NAME=$(odo app list | tail -n 1 | awk '{print $1}')
    echo $APP_NAME
}

function getPodName() {
    POD_NAME=$(kubectl get po -o name --selector=deploymentconfig=$COMPONENT_NAME-$APP_NAME)
    echo $POD_NAME
}

function getURL() {
    URL=$(odo url list | tail -n 1 | awk '{print $3}')
    echo $URL
}

function getPort() {
    PORT=$(odo url list | tail -n 1 | awk '{print $4}')
    echo $PORT
}

if [ $COMMAND == "getAppName"]; then
    getAppName
elif [ $COMMAND == "getPodName" ]; then
    COMPONENT_NAME=$1
    APP_NAME=$2
    getPodName
elif [ $COMMAND == "getURL" ]; then
    getURL
elif [ $COMMAND == "getPort"]; then
    getPort
fi
