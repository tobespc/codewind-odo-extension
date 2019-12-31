# Codewind OpenShift Do (odo) extension
[![License](https://img.shields.io/badge/License-EPL%202.0-red.svg?label=license&logo=eclipse)](https://www.eclipse.org/legal/epl-2.0/)
[![Build Status](https://ci.eclipse.org/codewind/buildStatus/icon?job=Codewind%2Fcodewind-odo-extension%2Fmaster)](https://ci.eclipse.org/codewind/job/Codewind/job/codewind-odo-extension/job/master/)
[![Chat](https://img.shields.io/static/v1.svg?label=chat&message=mattermost&color=145dbf)](https://mattermost.eclipse.org/eclipse/channels/eclipse-codewind)

Extension to Codewind providing support for OpenShift Do (odo) projects: https://codewind.dev

## Adding roles and importing Java image stream to support OpenShift Do (odo)
1. Log in to your OpenShift or Origin Community Distribution (OKD) cluster.
2. Enter the following commands to go to the correct location, add the roles and import Java image stream, and perform cleanup:
```
git clone https://github.com/eclipse/codewind-odo-extension &&\
   cd ./codewind-odo-extension/setup &&\
   ./setup.sh
   cd - &&\
   rm -rf codewind-odo-extension
```

## Current Limitations
- Only supports on Codewind for Eclipse Che with OKD/OpenShift cluster.
- Does not support project configuration.
- Does not support debug mode.
- Does not have HTTPS protocol support for accessing applications.

## Contributing 
We welcome submitting issues and contributions:
1. [Submitting issues](https://github.com/eclipse/codewind/issues)
2. [Contributing](CONTRIBUTING.md)
