#!/bin/bash

# ************************************
#  To be executed in the `tool container`!
# ************************************

# Basic global variables
PROJECT_NAME="ibm-vpc-roks-argocd-guestbook"
WORKSPACES_PATH="/home/devops/workspace"
MAPPED_VOLUME_PATH="/terraform"

# 1. Create workspace
mkdir ${WORKSPACES_PATH}
mkdir ${WORKSPACES_PATH}/${PROJECT_NAME}

# 2. Copy project into the workspace
# 2.1 Copy the helper scripts
cp -R . ${WORKSPACES_PATH} 
# 2.1 Copy the project content to the new workspace
cp ./${PROJECT_NAME}/*.* ${WORKSPACES_PATH}/${PROJECT_NAME}
# 2.3 Navigate to the new project in the new workspace
cd ${WORKSPACES_PATH}/${PROJECT_NAME}

# (optional) 3. Login to IBM Cloud
# ibmcloud login -sso
