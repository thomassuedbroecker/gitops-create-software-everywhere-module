# gitops-create-software-everywhere-module

# Objective

The objective is to understand how to build new modules for the [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/).

# What does the project do?

This project does inspect the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) and needs to be seen in combination with the [gitops-verify-swagger-editor-example](https://github.com/thomassuedbroecker/gitops-verify-swagger-editor-example) outcome.

## Understand the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops)

The [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) is a part of the `How to` instructions of the [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/). 
The module covers the [GitOps topic](https://modules.cloudnativetoolkit.dev/#/how-to/gitops).

# Use the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) to create a module to deploy the guestbook example

These are the main tasks:

1. Create a GitHub repository based on the `gitops template` from `Software Everywhere`
2. Configure the `guestbook` `module`
3. Create an own `catalog` for the `guestbook` `module`
4. Create a `BOM` where the `guestbook` `module` is used and create the needed terraform output with `iascable`

## Perpare the environment

### Create a new GitHub repository based on the `gitops template`

We will use later different catalogs here is a simplified view of the depencencies we will have later.

![](images/develop-own-module-01.png)

#### Step 1: Clone the project to your local computer

```sh
git clone https://github.com/cloud-native-toolkit/template-terraform-gitops
```

#### Step 2: Delete the **`.git`** folder in the cloned project to disconnect the git repository

#### Step 3: Rename the root folder of the project from `template-terraform-gitops` to `gitops-terraform-guestbook`

#### Step 4: Run the git init command in the `gitops-terraform-guestbook` folder

That will create a new `.git` folder.

```sh
git init
```

* Output

```sh
hint: Using 'master' as the name for the initial branch. This default branch name
hint: is subject to change. To configure the initial branch name to use in all
hint: of your new repositories, which will suppress this warning, call:
hint: 
hint:   git config --global init.defaultBranch <name>
hint: 
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint: 
hint:   git branch -m <name>
Initialized empty Git repository in /Users/thomassuedbroecker/Downloads/dev/gitops-terraform-guestbook/.git/
```

#### Step 4: Execute the `git add --all` command

```sh
git add --all
```

#### Step 5: Create new GitHub project [`gitops-terraform-guestbook`](https://github.com/thomassuedbroecker/gitops-terraform-guestbook) using `git commit`

```sh
git commit
```

* Interactive output:

It opens a `vi editor`. 
1. Enter `I`
2. Now you can insert some text `Init repo`.
3. Press `esc`
4. Press `:`
5. Insert `wq`

```sh

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch master
#
# Initial commit
#
# Changes to be committed:
#       new file:   .DS_Store
#       new file:   .github/.DS_Store
#       new file:   .github/release-drafter.yaml
#       new file:   .github/scripts/validate-deploy.sh
#       new file:   .github/scripts/validation-functions.sh
#       new file:   .github/workflows/manual-test-repo-delete.yaml
#       new file:   .github/workflows/notify.yaml
#       new file:   .github/workflows/publish-metadata.yaml
```

#### Step 6: Create a new empty GitHub repository with the name `gitops-terraform-guestbook`

#### Step 7: Connect to GitHub 

```sh
git branch -M main
USERNAME=YOUR_USERNAME
REPONAME=gitops-terraform-guestbook
git remote add origin git@github.com:$USERNAME/$REPONAME
```

#### Step 7: Push to the `master` branch

> If you don't have a [`ssh key`](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

```sh
git push -u origin main
```

### 2. Configure the `guestbook` module 


#### Step 1:  Do some modification in the `main.tf` file

* Change `name = "my-helm-chart-folder"` to `helm-guestbook`
* First add `helm_guestbook = {// create entry}` to the `values_content = {}`. That entry will be used to create the values for the variables in the `values.yaml` file for the helm chart.
  
  Below you see the relevant code in the `main.tf` which does the copy later. As you can is it uses the `{local.name}` value, so you need to ensure the name reflects the folder structure for your `helm-chart` later.

  ```sh
  resource null_resource create_yaml {
    provisioner "local-exec" {
      command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"
  
      environment = {
        VALUES_CONTENT = yamlencode(local.values_content)
      }
    }
  }
  ```

  These are the values we need to insert for our guestbook application as variables for the helm-chart. You find the variables in the Argo CD github project for the helm guestbook application [values.yaml](https://github.com/argoproj/argocd-example-apps/blob/master/helm-guestbook/values.yaml)

  Now replace the `// create entry` with the needed values.

  ```sh
    helm_guestbook = {
      "replicaCount": 1
      "image.repository" = "gcr.io/heptio-images/ks-guestbook-demo"
      "image.tag" = "0.1"
      "image.pullPolicy" = "IfNotPresent"
      "service.type" = "ClusterIP"
      "service.port" = "80"
      "ingress.enabled" = "false"
      "ingress.annotations" = ""
      "ingress.path" = "/"
      "ingress.hosts" = ["chart-example.local"]
      "ingress.tls" = []
      "resources" = ""
      "nodeSelector" = ""
      "tolerations" = ""
      "affinity" = ""
    }
  ```
* Change `layer = "services"` to `layer = "applications"`
* Add `cluster_type = var.cluster_type == "kubernetes" ? "kubernetes" : "openshift"` to the `locals`

```
locals {
  name          = "my-helm-chart-folder"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  values_content = {
    helm_guestbook = {
      // create entry
    }
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}
```

#### Step 2:  Add some variable in the `variable.tf` file

```hcl
variable "cluster_type" {
  description = "The cluster type (openshift or kubernetes)"
  default     = "openshift"
}
```

#### Step 2: Create a new folder structure for the `guestbook helmchart`

* Create following folder structure `chart/helm-guestbook`.
  The name after chart must be the module name.

  ```sh
  ├── chart
  │   └── helm-guestbook
  │       ├── Chart.yaml
  │       ├── charts
  │       │   └── helm-guestbook
  │       │       ├── templates
  │       │       │   ├── NOTES.txt
  │       │       │   ├── _helpers.tpl
  │       │       │   ├── deployment.yaml
  │       │       │   └── service.yaml
  │       │       ├── values-production.yaml
  │       │       └── values.yaml
  │       │       └── Chart.yaml
  │       └── values.yaml
  ```

#### Step 3: Copy in newly create folderstructure the content from the repository for the `helm-guestbook` chart [https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook](https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook)

#### Step 4: Validate the `helm chart` with following commands:

* Navigate the charts directory

```sh
CHARTDIR=./chart/helm-guestbook/charts/helm-guestbook
cd $CHARTDIR
```

* Verify the dependencies

```sh
helm dep update .
```

* Verify the helm chart structure

```sh
helm lint .
```

Example output:

```sh
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

```sh
helm template test . -n test
```

Example output:

```sh
# Source: helm-guestbook/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: test-helm-guestbook
  labels:
    app: helm-guestbook
    chart: helm-guestbook-0.1.0
    release: test
    heritage: Helm
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app: helm-guestbook
    release: test
---
# Source: helm-guestbook/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-helm-guestbook
  labels:
    app: helm-guestbook
    chart: helm-guestbook-0.1.0
    release: test
    heritage: Helm
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: helm-guestbook
      release: test
  template:
    metadata:
      labels:
        app: helm-guestbook
        release: test
    spec:
      containers:
        - name: helm-guestbook
          image: "gcr.io/heptio-images/ks-guestbook-demo:0.1"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {}
```

#### Step 3: Edited the `module.yaml` 

* Use for `name`: `gitops-terraform-guestbook`
* Use for `description`: `That module will add a new Argo CD config to deploy the guestbook application`

```yaml
name: ""
type: gitops
description: ""
tags:
  - tools
  - gitops
versions:
  - platforms:
      - kubernetes
      - ocp3
      - ocp4
    dependencies:
      - id: gitops
        refs:
          - source: github.com/cloud-native-toolkit/terraform-tools-gitops.git
            version: ">= 1.1.0"
      - id: namespace
        refs:
          - source: github.com/cloud-native-toolkit/terraform-gitops-namespace.git
            version: ">= 1.0.0"
    variables:
      - name: gitops_config
        moduleRef:
          id: gitops
          output: gitops_config
      - name: git_credentials
        moduleRef:
          id: gitops
          output: git_credentials
      - name: server_name
        moduleRef:
          id: gitops
          output: server_name
      - name: namespace
        moduleRef:
          id: namespace
          output: name
      - name: kubeseal_cert
        moduleRef:
          id: gitops
          output: sealed_secrets_cert
```

### Step 4: Create GitHub tag and relase

The module github repository releases shoulf be updated when you are going to change the module.
In case when you use specific version numbers in the `BOM` which consums the module.

Example relevant extract from a `BOM` -> `version: v0.0.5`

```yaml
    # Install guestbook
    # New custom module linked be the custom catalog
    - name: gitops-terraform-guestbook
      # alias: gitops-terraform-guestbook
      #  version: v0.0.5
      # variables:
      #  - name: namespace_name
      #    value: "helm-guestbook"
```

You can follow the step to create a GitHub tag is that [example blog post](https://suedbroecker.net/2022/05/09/how-to-create-a-github-tag-for-your-last-commit/) and then create a release.

#### Step 5: Configure the `scripts/create-yaml.sh` in `gitops-terraform-guestbook` repository 

Replace the existing code in `scripts/create-yaml.sh` with following content. This is important for later when the `helm-chart` will be copied.

```sh
#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../chart/helm-guestbook"; pwd -P)

NAME="$1"
DEST_DIR="$2"

## Add logic here to put the yaml resource content in DEST_DIR
mkdir -p "${DEST_DIR}"
cp -R "${CHART_DIR}/"* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi
find "${DEST_DIR}" -name "*"
echo "Files in output path"
ls -l "${DEST_DIR}"
```

### 3. Create an own catalog

In that example we will not publish the our `gitops-terraform-guestbook` module to the public catalog on [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/). 

We will create our own `catalog.yaml` file and save the configuration in the GitHub project of the module.

* How to create `catalog.yaml` file ?

  It is useful to take a look into [iascable documentation](https://github.com/cloud-native-toolkit/iascable) and the [build-catalog.sh automation](https://github.com/cloud-native-toolkit/software-everywhere/blob/main/.github/scripts/build-catalog.sh).

* How to combine various catalogs?

  You can combine more than one `catalog resources` and `BOM inputs` with the `iascable build` command.

  Here is the build command:

  ```sh
  iascable build [-c {CATALOG_URL}] [-c {CATALOG_URL}] -i {BOM_INPUT} [-i {BOM_INPUT}] [-o {OUTPUT_DIR}]
  ```

  * `CATALOG_URL` is the url of the module catalog. The default module catalog is https://modules.cloudnativetoolkit.dev/index.yaml. Multiple module catalogs can be provided. The catalogs are combined, with the last one taking precedence in the case of duplicate modules.
  * `BOM_INPUT` is the input file containing the Bill of Material definition. Multiple BOM files can be provided at the same time.
  * `OUTPUT_DIR` is the directory where the output terraform template will be generated.

* Inspect the structure of a `catalog.yaml`

  The structure of a catalog can be verified here
  [https://modules.cloudnativetoolkit.dev/index.yaml](https://modules.cloudnativetoolkit.dev/index.yaml)
  That is a minimize extraction of the `index.yaml` above. It contains: `categories`,`modules`,`aliases` and `providers`.

  ```yaml
  apiVersion: cloudnativetoolkit.dev/vlalphal
  kind: Catalog
  categories:
    - category: ai-ml
    - category: cluster
    - category: databases
    - category: dev-tool
    - category: gitops
      categoryName: GitOps
      selection: multiple
      modules:
        - cloudProvider: ""
          softwareProvider: ""
          type: gitops
          name: gitops-ocs-operator
          description: Module to populate a gitops repo with the resources to provision ocs-operator
          tags:
            - tools
            - gitops
          versions: []
          id: github.com/cloud-native-toolkit/terraform-gitops-ocs-operator
          group: ""
          displayName: ocs-operator
    - category: iam
    - category: image-registry
    - category: infrastructure
    ...
  aliases:
    - id: github.com/terraform-ibm-modules/terraform-ibm-toolkit-mongodb
    ...
  providers:
    - name: ibm
      source: ibm-cloud/ibm
      variables:
        - name: ibmcloud_api_key
          scope: global
        - name: region
          scope: global
  ```

* Inspect the module section of the catalog file in more detail

  We see that the `modules section` does contain following `cloudProvider`, `softwareProvider`, `id`, `group`, `displayName` and `type` which are not a part of the `module.yaml`. After these entries we insert content of the `module.yaml`.

  [Current `gitops` template](https://github.com/cloud-native-toolkit/template-terraform-gitops).

#### Step 1: Create a `guestbook-catalog.yml` and insert following content

> Note: Ensure that the github project has a tag and a release!

**The right value of the release** must be reference in the catalog! (Example `version: v0.0.1`).

  ```yaml
  apiVersion: cloudnativetoolkit.dev/v1alpha1
  kind: Catalog
  categories:
    - category: custom_module
      categoryName: custom_module
      selection: multiple
      modules:
        - cloudProvider: ""
          softwareProvider: ""
          type: gitops
          id: github.com/thomassuedbroecker/gitops-terraform-guestbook
          group: ""
          displayName: gitops-terraform-guestbook
          name: gitops-terraform-guestbook
          description: asdf
          tags:
            - tools
            - gitops
          versions:
            - platforms:
                - kubernetes
                - ocp3
                - ocp4
              dependencies:
                - id: gitops
                  refs:
                    - source: github.com/cloud-native-toolkit/terraform-tools-gitops.git
                      version: '>= 1.1.0'
              variables:
                - name: gitops_config
                  description: Config information regarding the gitops repo structure
                  moduleRef:
                    id: gitops
                    output: gitops_config
                - name: git_credentials
                  description: The credentials for the gitops repo(s)
                  sensitive: true
                  moduleRef:
                    id: gitops
                    output: git_credentials
                - name: namespace
                  type: string
                  description: The namespace where the application should be deployed
                  moduleRef:
                    id: namespace
                    output: name
                - name: kubeseal_cert
                  type: string
                  description: The certificate/public key used to encrypt the sealed secrets
                  default: ""
                  moduleRef:
                    id: gitops
                    output: sealed_secrets_cert
                - name: server_name
                  type: string
                  description: The name of the server
                  default: default
                  moduleRef:
                    id: gitops
                    output: server_name
              version: v0.0.1
              outputs:
                - name: name
                  description: The name of the module
                - name: branch
                  description: The branch where the module config has been placed
                - name: namespace
                  description: The namespace where the module will be deployed
                - name: server_name
                  description: The server where the module will be deployed
                - name: layer
                  description: The layer where the module is deployed
                - name: type
                  description: The type of module where the module is deployed
  ```

### Verify the `BOM` to use the `guestbook module` and use [`iascable`](https://github.com/cloud-native-toolkit/iascable)


#### Step 1: Install [`iascable`](https://github.com/cloud-native-toolkit/iascable)

To ensure you use the lates version.

```sh
curl -sL https://iascable.cloudnativetoolkit.dev/install.sh | sh
iascable --version
```

Example output:
```sh
2.17.2
```

#### Step 2: Clone the project with the example BOM configuration 

```sh
git clone https://github.com/thomassuedbroecker/gitops-create-software-everywhere-module
```

#### Step 3: Verify the `ibm-vpc-roks-argocd-guestbook.yaml` `BOM` file

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: ibm-vpc-roks-argocd-guestbook
spec:
  modules:
    # Virtual Private Cloud - related
    # - subnets
    # - gateways
    - name: ibm-vpc
      alias: ibm-vpc
      version: v1.16.1
      variables:
      - name: name
        value: "tsued-gitops-guestbook"
      - name: tags
        value: ["tsuedro"]
    - name: ibm-vpc-subnets
      alias: ibm-vpc-subnets
      version: v1.13.2
      variables:
        - name: _count
          value: 1
        - name: name
          value: "tsued-gitops-guestbook"
        - name: tags
          value: ["tsuedro"]
    - name: ibm-vpc-gateways
    # ROKS - related
    # - objectstorage
    - name: ibm-ocp-vpc
      alias: ibm-ocp-vpc
      version: v1.15.7
      variables:
        - name: name
          value: "tsued-gitops-guestbook"
        - name: worker_count
          value: 2
        - name: tags
          value: ["tsuedro"]
    - name: ibm-object-storage
      alias: ibm-object-storage
      version: v4.0.3
      variables:
        - name: name
          value: "cos_tsued_guestbook"
        - name: tags
          value: ["tsuedro"]
        - name: label
          value: ["cos_tsued_guestbook"]
    # Install OpenShift GitOps and Bootstrap GitOps (aka. ArgoCD) - related
    # - argocd
    # - gitops
    - name: argocd-bootstrap
      alias: argocd-bootstrap
      version: v1.12.0
      variables:
        - name: repo_token
    - name: gitops-repo
      alias: gitops-repo
      version: v1.20.2
      variables:
        - name: host
          value: "github.com"
        - name: type
          value: "GIT"
        - name: org
          value: "thomassuedbroecker"
        - name: username
          value: "thomassuedbroecker"
        - name: project
          value: "iascable-gitops-guestbook"
        - name: repo
          value: "iascable-gitops-guestbook"
    # Install guestbook
    # New custom module linked be the custom catalog
    - name: gitops-terraform-guestbook
      #  alias: gitops-terraform-guestbook
      #  version: v0.0.5
      variables:
        - name: namespace
          value: "helm-guestbook"
```

#### Step 4:  Update helper scripts

```sh
cd example
ls
```

These are the helper scripts:

  * helper-create-scaffolding.sh                            
  * helper-tools-create-container-workspace.sh              
  * helper-tools-execute-apply-and-backup-result.sh         
  * helper-tools-execute-destroy-and-delete-backup.sh

* Update helper script `helper-create-scaffolding.sh` with following code that uses two catalog files as input for the terraform creation with `iascable`.

```sh
BASE_CATALOG=https://modules.cloudnativetoolkit.dev/index.yaml
CUSTOM_CATALOG=https://raw.githubusercontent.com/thomassuedbroecker/gitops-terraform-guestbook/main/guestbook-catalog.yml

# 1. Create scaffolding
iascable build -i ibm-vpc-roks-argocd-guestbook.yaml -c $BASE_CATALOG -c $CUSTOM_CATALOG
```

#### Step 7: Execute "helper-create-scaffolding.sh"

```sh
sh helper-create-scaffolding.sh 
```

#### Step 8: Delete the `-u "${UID}" \` command from the `output/launch.sh` script

```sh
${DOCKER_CMD} run -itd --name ${CONTAINER_NAME} \
  --device /dev/net/tun --cap-add=NET_ADMIN \
  -u "${UID}" \
  -v "${SRC_DIR}:/terraform" \
  -v "workspace-${AUTOMATION_BASE}:/workspaces" \
  ${ENV_VARS} -w /terraform \
  ${DOCKER_IMAGE}
```

#### Step 9: Start the `launch.sh script`

```sh
cd output
sh launch.sh
```

#### Step 10: Execute in the `tools container` the "helper-tools-create-container-workspace.sh" script

```sh
/terraform $
```

```sh
sh helper-tools-create-container-workspace.sh 
```

#### Step 11: Execute in the `tools container` the "helper-tools-execute-apply-and-backup-result.sh" script

```sh
/terraform $
```

```sh
sh helper-tools-execute-apply-and-backup-result.sh 
```

Interactive output:

* Namespace: guestbook
* Region: eu-de
* Resource group: default

```sh
Provide a value for 'gitops-repo_host':
  The host for the git repository. The git host used can be a GitHub, GitHub Enterprise, Gitlab, Bitbucket, Gitea or Azure DevOps server. If the host is null assumes in-cluster Gitea instance will be used.
> (github.com) 
Provide a value for 'gitops-repo_org':
  The org/group where the git repository exists/will be provisioned. If the value is left blank then the username org will be used.
> (thomassuedbroecker) 
Provide a value for 'gitops-repo_project':
  The project that will be used for the git repo. (Primarily used for Azure DevOps repos)
> (iascable-gitops-guestbook) 
Provide a value for 'gitops-repo_username':
  The username of the user with access to the repository
> (thomassuedbroecker) 
Provide a value for 'gitops-repo_token':
> XXX
> Provide a value for 'ibmcloud_api_key':
> XXX
Provide a value for 'region':
> eu-de
Provide a value for 'worker_count':
  The number of worker nodes that should be provisioned for classic infrastructure
> (2) 
Provide a value for 'ibm-ocp-vpc_flavor':
  The machine type that will be provisioned for classic infrastructure
> (bx2.4x16) 
Provide a value for 'ibm-vpc-subnets__count':
  The number of subnets that should be provisioned
> (1) 
Provide a value for 'namespace_name':
  The value that should be used for the namespace
> guestbook
Provide a value for 'resource_group_name':
  The name of the resource group
> default
```

#### Step 12: Verify the output of terraform execution

After some time you should get following output:

```sh
Apply complete! Resources: 103 added, 0 changed, 0 destroyed.
```

### Verify the created Argo CD configuration on GitHub

We see that in our GitHub account new repostory was created from the GitOps bootstap module to figure `Argo CD` for a using the `app-of-apps` concept with a single GitHub repository to manage all application in the GitOps context.

The repository is called `iascable-gitops-guestbook` in our case.

The repository contains two folders:

1. **argocd** folder which contains the configuration for `Argo CD` let us call it `**app-of-apps** folder`. The following image displays the resulting configuration in `Argo CD`

![](images/develop-own-module-03.png)


2. **payload** folder which contains the current helm deployment for the **apps** which will be deployed. The following image show the deployment created by `apps` in our case the helm-guestbook 

The following image show the create GitHub project

![](images/develop-own-module-02.png)

For more details visit the template of the [terraform-tools-gitops](https://github.com/cloud-native-toolkit/terraform-tools-gitops/tree/main/template) module.

### Understand how the `guestbook module content` was pasted into the new repository

1. `Argo CD application configuration` to deploy the guestbook application

Therefor we defined the values content before in the `module.tf` file.

```hcl
  values_content = {
    helm_guestbook = {
      // create entry
    }
  }
```

These will be use in the first `values.yaml` file in the payload directory.

That first directory is used as the `source.path` in the `Argo CD` application configuration.

This is the Argo CD application configuration `guestbook-helm-guestbook.yaml` file, which was created automaticly by our module with the `igc gitops-module` command.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-helm-guestbook
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: guestbook
    server: https://kubernetes.default.svc
  project: 3-applications
  source:
    path: payload/3-applications/namespace/guestbook/helm-guestbook
    repoURL: https://github.com/thomassuedbroecker/iascable-gitops-guestbook.git
    targetRevision: main
    helm:
      releaseName: helm-guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
  ignoreDifferences: []
```

2. `Helm guestbook application` deployment

The script `scripts/create-yaml.sh` of our [module `gitops-terraform-guestbook`](https://github.com/thomassuedbroecker/gitops-terraform-guestbook) was resposible to copy the guestbook helm-chart into the payload directory. Therefor we did the customization of that file.






