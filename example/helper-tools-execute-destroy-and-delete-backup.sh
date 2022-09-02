#!/bin/bash

# ************************************
# To be executed in the `tool container`!
# ************************************

# Basic global variables
#PROJECT_NAME="ibm-vpc-roks-argocd-guestbook"
PROJECT_NAME="niklas-example"
WORKSPACES_PATH="/home/devops/workspace"
MAPPED_VOLUME_PATH="/terraform"

# 1. Navigate to workspace
pwd
cd ${WORKSPACES_PATH}/${PROJECT_NAME}

# 2. Execute destroy.sh
sh destroy.sh

# 3. Navigate to the mapped volume
cd ${MAPPED_VOLUME_PATH}

# 4. Copy the state to the mapped volume
cp -Rf ${WORKSPACES_PATH}/${PROJECT_NAME} ${MAPPED_VOLUME_PATH}


