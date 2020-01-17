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

OS=$(uname -a | awk '{print $1;}')

# Bind (rolebinding) additional cluster roles to Codewind service account(s)
SERVICE_ACCOUNTS=$(kubectl get po --selector=app=codewind-pfe -o jsonpath='{.items[*].spec.containers[*].env[?(@.name=="SERVICE_ACCOUNT_NAME")].value}')
for SERVICE_ACCOUNT in $SERVICE_ACCOUNTS; do
    echo "Bind (rolebinding) additional cluster roles to Codewind service account: $SERVICE_ACCOUNT"

    if [ $OS == "Darwin" ]; then
        sed -i ' ' "s/<serviceaccount>/$SERVICE_ACCOUNT/g" codewind-odorolebinding.yaml
    elif [ $OS == "Linux" ]; then
        sed -i "s/<serviceaccount>/$SERVICE_ACCOUNT/g" codewind-odorolebinding.yaml
    fi

    kubectl apply -f codewind-odoclusterrole.yaml
    kubectl apply -f codewind-odorolebinding.yaml
done

# Import Java image stream to the cluster
./odo-addbuilder.sh
