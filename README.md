# codewind-odo-extension
Extension to Codewind providing support for odo projects: https://codewind.dev

Add additional rules to support ODO extension
ODO extension needs add additional rules for accessing OpenShift resources
Steps to add additional rules:
1. In your home directory, run the following command to clone the ODO extension repository
`git clone https://github.com/eclipse/codewind-odo-extension`
2. Login to your OpenShift/OKD cluster
3. Go into `~/codewind-odo-extension/odo-RBAC` then run the following commands to add additional rules
`kubectl apply -f codewind-odoclusterrole.yaml`
`kubectl apply -f codewind-odoclusterrolebinding.yaml`


Install ODO extension manually
1. In your home directory, run the following command to clone the ODO extension repository
`git clone https://github.com/eclipse/codewind-odo-extension`
2. Copy the ODO extension repository to `/codewind-workspace/.extensions` directory in the PFE container
3. Shell into the PFE container then run `mkdir -p /codewind-workspace/.extensions/codewind-odo-extension/bin` to create the bin folder for ODO extension
4. Shell into the PFE container then download ODO CLI to `/codewind-workspace/.extensions/codewind-odo-extension/bin` by using `curl -L https://github.com/openshift/odo/releases/latest/download/odo-linux-amd64 -o /codewind-workspace/.extensions/codewind-odo-extension/bin/odo && chmod +x /codewind-workspace/.extensions/codewind-odo-extension/bin/odo`
5 Restart the node server inside PFE container to load the ODO extension
Note: We already had installer for ODO extension, the installer will help you automatically install ODO extension if you are running Codewind on OKD/OpenShift cluster, this is only workaround when installer doesn't work properly


Current Limitations
- ODO extension is supported on Codewind for Eclipse Che with OKD/OpenShift cluster
- ODO extension doesn't support project configuration
- ODO extension doesn't support debug mode
- ODO extension doesn't have HTTPS protocol support for accessing applications
