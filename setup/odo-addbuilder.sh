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

# Import OpenShift image stream
oc import-image codewind-odo-openjdk18 --from=registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift --confirm --overwrite=true

# Tag the image as a builder
oc annotate istag/codewind-odo-openjdk18:latest tags=builder --overwrite=true
