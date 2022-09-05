#!/bin/bash

# Basic global variables
CONTAINER_ENGINE="colima"
BASE_CATALOG=https://modules.cloudnativetoolkit.dev/index.yaml
CUSTOM_CATALOG=https://raw.githubusercontent.com/thomassuedbroecker/gitops-terraform-guestbook/main/guestbook-catalog.yml

# 1. Create scaffolding
iascable build -i ibm-vpc-roks-argocd-guestbook.yaml -c $BASE_CATALOG -c $CUSTOM_CATALOG

# 2. Copy helper bash scipts into the output folder
cp helper-tools-create-container-workspace.sh ./output
cp helper-tools-execute-apply-and-backup-result.sh ./output
cp helper-tools-execute-destroy-and-delete-backup.sh ./output

# 3. Navigate to created 'scaffolding'
cd output

# 4. Start container engine
"${CONTAINER_ENGINE}" start

# 5. Start tools container
#sh launch.sh
echo "*********************"
echo "Please delete the <-u '${UID}' \> command from the <output/launch.sh> script"
echo "*********************"