# gitops-create-software-everywhere-module

# Objective

The objective is to understand how to build new modules for the [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/).

# What does the project do?

This project does inspect the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) and needs to be seen in combination with the [gitops-verify-swagger-editor-example](https://github.com/thomassuedbroecker/gitops-verify-swagger-editor-example) outcome.

## Understand the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops)

The [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) is a part of the `How to` instructions of the [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/). 
The module covers the [GitOps topic](https://modules.cloudnativetoolkit.dev/#/how-to/gitops).

# Use the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) to create a module to deploy the guestbook example

## Perpare the environment

### a. Create a new GitHub repository based on the template

#### Step 1: Clone the project to your local computer

```sh
git clone https://github.com/cloud-native-toolkit/template-terraform-gitops
```

#### Step 2: Delete the `.git` folder in the cloned project to disconnect the git repository

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

#### Step 5: Create new github project `gitops-terraform-guestbook` using `git commit`

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

* Change `name = "my-module"` to `guestbook-module`
* Add `helm_guestbook = {// create entry}` to the `values_content = {}`. 
* Change `layer = "services"` to `layer = "applications"`

```
locals {
  name          = "my-module"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  values_content = {
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}
```

#### Step 2: Create a new folder structure for the `guestbook helmchart`

* Create following folder structure `chart/helm-guestbook`
* Copy in newly created `chart/helm-guestbook` the content from the repository for the `helm-guestbook` chart [https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook](https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook)

#### Step 3: Edited the `module.yaml` 

* Use for `name`: `gitops-guestbook-module`
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