# GitOps repo module

Module that prepares a GitOps repo for use with ArgoCD. If the `provision` flag is `true` then a new git repo will be provisioned. If not, the provided repo name is expected to already exist.

After cloning the git repo, an initial directory structure is set up along with bootstrap configuration to perform the initial setup of ArgoCD.

## Supported git servers

The module supports creating a repository in one of six different git servers:

- GitHub
- GitHub Enterprise
- Gitlab
- Bitbucket
- Gitea
- Azure DevOps

The selection of the git server type is determined by the value provided for the `host` and the returned api headers.

## Default git server config

This module allows for fall-back git server configuration if the git server configuration values are not
provided as input. This default git server is typically Gitea and previously the gitea config values were explicitly
provided as direct input to this module. With a recent change, these values have been removed and should be provided
via the `gitops` provider configuration in the `default_***` fields. See [example/provider.tf](example/provider.tf) for
an example of this configuration.

**Note:** This is actually how the test case is configured. For all the test cases, the gitea config is provided for 
the default git server information. When the test case is non-gitea, the git server information is provided in the `host`,
`org`, `username`, and `token` fields. For the gitea test case, those fields are left blank and the gitea config is used.

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform >= v0.15
- git

### Terraform providers

- cloud-native-toolkit/gitops
- cloud-native-toolkit/clis

## Module dependencies

This module makes use of the output from other modules:

- Sealed Secret Cert - github.com/cloud-native-toolkit/terraform-util-sealed-secret-cert

## Example usage

See [example/](example) folder for full example usage

```hcl-terraform
module "git" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitops"

  host = var.git_host
  org  = var.git_org
  repo = var.git_repo
  username = var.git_username
  token = var.git_token
  project = var.git_project
  gitops_namespace = var.gitops_namespace
  sealed_secrets_cert = module.cert.cert
  strict = var.gitops_strict
}
```

