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
ODO_CLI=$ODO_EXTENSION_DIR/bin/odo

# General setup
source /file-watcher/scripts/constants.sh
set -o pipefail
util=/file-watcher/scripts/util.sh

COMMAND=$1
shift 1

function getAppName() {
    APP_NAME=$($ODO_CLI app list | tail -n 1 | awk '{print $1}')
    echo $APP_NAME
}

function getPodName() {
    POD_NAME=$(kubectl get po -o name --selector=deploymentconfig=$COMPONENT_NAME-$APP_NAME)
    echo $POD_NAME
}

function getURL() {
    URL=$($ODO_CLI url list | tail -n 1 | awk '{print $3}')
    echo $URL
}

function getPort() {
    PORT=$($ODO_CLI url list | tail -n 1 | awk '{print $4}')
    echo $PORT
}

function addOwnerReference() {
    PFE_LABEL="app=codewind-pfe,codewindWorkspace=$CHE_WORKSPACE_ID"
    COMPONENT_LABEL="app.kubernetes.io/instance=$COMPONENT_NAME"
    APP_LABEL="app.kubernetes.io/part-of=$APP_NAME"
    PFE_NAME=$(kubectl get rs --selector=$PFE_LABEL -o jsonpath='{.items[0].metadata.name}')
    PFE_UID=$(kubectl get rs --selector=$PFE_LABEL -o jsonpath='{.items[0].metadata.uid}')
    RESOURCES=('deploymentconfig' 'imagestream')

    for RESOURCE in "${RESOURCES[@]}"; do
        echo "Adding owner reference to resource: $RESOURCE" |& tee -a $ODO_DEBUG_LOG
        RESOURCE_NAME=$(kubectl get $RESOURCE --selector=$COMPONENT_LABEL,$APP_LABEL -o jsonpath='{.items[0].metadata.name}')
        kubectl patch $RESOURCE $RESOURCE_NAME --patch '{"metadata": {"ownerReferences": [{"apiVersion": "apps/v1", "blockOwnerDeletion": true, "controller": true, "kind": "ReplicaSet", "name": "'$PFE_NAME'", "uid": "'$PFE_UID'"}]}}'
        if [ $? -ne 0 ]; then
            exit 1
        fi
    done
}

if [ $COMMAND == "getAppName" ]; then
    getAppName
elif [ $COMMAND == "getPodName" ]; then
    COMPONENT_NAME=$1
    APP_NAME=$2
    getPodName
elif [ $COMMAND == "getURL" ]; then
    getURL
elif [ $COMMAND == "getPort" ]; then
    getPort
elif [ $COMMAND == "addOwnerReference" ]; then
    COMPONENT_NAME=$1
    APP_NAME=$2
    ODO_DEBUG_LOG=$3
    addOwnerReference
fi
