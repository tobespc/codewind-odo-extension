# Codewind ODO extension
Extension to Codewind providing support for ODO projects: https://codewind.dev

## Add additional rules to support Codewind ODO extension
The ODO extension needs to add additional rules for accessing OpenShift resources:
1. In your home directory, run the following command to clone the ODO extension repository:
`git clone https://github.com/eclipse/codewind-odo-extension`
2. Login to your OpenShift/OKD cluster
3. Go into `~/codewind-odo-extension/odo-RBAC` then run the following commands to add additional rules:
`kubectl apply -f codewind-odoclusterrole.yaml`
`kubectl apply -f codewind-odoclusterrolebinding.yaml`

## Install Codewind ODO extension manually
1. In your home directory, run the following commands to clone the ODO extension repository:
`git clone https://github.com/eclipse/codewind-odo-extension`
2. Copy the ODO extension repository to `/codewind-workspace/.extensions` directory in the PFE container
3. Shell into the PFE container then run `mkdir -p /codewind-workspace/.extensions/codewind-odo-extension/bin` to create the bin folder for ODO extension
4. Shell into the PFE container then download ODO CLI to `/codewind-workspace/.extensions/codewind-odo-extension/bin` by using `curl -L https://github.com/openshift/odo/releases/latest/download/odo-linux-amd64 -o /codewind-workspace/.extensions/codewind-odo-extension/bin/odo && chmod +x /codewind-workspace/.extensions/codewind-odo-extension/bin/odo`
5. Restart the node server inside the PFE container to load the ODO extension
Note: We already have an installer for the ODO extension. The installer will help you automatically install the ODO extension. If you are running Codewind on an OKD/OpenShift cluster, this is the only workaround when the installer does not work properly.

## Current Limitations
- ODO extension is supported on Codewind for Eclipse Che with an OKD/OpenShift cluster
- ODO extension does not support project configuration
- ODO extension does not support debug mode
- ODO extension does not have HTTPS protocol support for accessing applications

## Contributing 
We welcome submitting issues and contributions:
1. [Submitting issues](https://github.com/eclipse/codewind/issues)
2. [Contributing](CONTRIBUTING.md)
