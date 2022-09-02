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
cp -R . ${WORKSPACES_PATH}
cp ./${PROJECT_NAME}/*.* ${WORKSPACES_PATH}/${PROJECT_NAME}
cd ${WORKSPACES_PATH}/${PROJECT_NAME}
