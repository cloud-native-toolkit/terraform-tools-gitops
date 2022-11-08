
output "config_host" {
  value = gitops_repo.repo.host
  description = "The host name of the bootstrap git repo"
}

output "config_org" {
  value = gitops_repo.repo.org
  description = "The org name of the bootstrap git repo"
}

output "config_name" {
  value = gitops_repo.repo.repo
  description = "The repo name of the bootstrap git repo"
}

output "config_project" {
  value = gitops_repo.repo.project
  description = "The project name of the bootstrap git repo (for Azure DevOps)"
}

output "config_repo" {
  value = gitops_repo.repo.repo
  description = "The repo that contains the argocd configuration"
}

output "config_repo_url" {
  value = gitops_repo.repo.url
  description = "The repo that contains the argocd configuration"
}

output "config_username" {
  value       = gitops_repo.repo.username
  description = "The username for the config repo"
}

output "config_token" {
  value       = gitops_repo.repo.token
  description = "The token for the config repo"
  sensitive   = true
  depends_on  = [gitops_repo.repo]
}

output "config_paths" {
  description = "The paths in the config repo"
  value = {
    infrastructure = "argocd/1-infrastructure"
    services       = "argocd/2-services"
    applications   = "argocd/3-applications"
  }
  depends_on = [gitops_repo.repo]
}

output "config_projects" {
  description = "The ArgoCD projects for the different layers of the repo"
  value = {
    infrastructure = "1-infrastructure"
    services       = "2-services"
    applications   = "3-applications"
  }
  depends_on = [gitops_repo.repo]
}

output "bootstrap_path" {
  description = "The path to the bootstrap configuration"
  value       = local.bootstrap_path
  depends_on = [gitops_repo.repo]
}

output "bootstrap_branch" {
  description = "The branch in the gitrepo containing the bootstrap configuration"
  value       = gitops_repo.repo.branch
  depends_on = [gitops_repo.repo]
}

output "application_repo" {
  value = gitops_repo.repo.repo
  description = "The repo that contains the application configuration"
}

output "application_repo_url" {
  value = gitops_repo.repo.url
  description = "The repo that contains the application configuration"
}

output "application_username" {
  value       = gitops_repo.repo.username
  description = "The username for the application repo"
}

output "application_token" {
  value       = gitops_repo.repo.token
  description = "The token for the application repo"
  sensitive   = true
}

output "application_paths" {
  description = "The paths in the application repo"
  value = {
    infrastructure = "payload/1-infrastructure"
    services       = "payload/2-services"
    applications   = "payload/3-applications"
  }
  depends_on = [gitops_repo.repo]
}

output "gitops_config" {
  description = "Config information regarding the gitops repo structure"
  value = local.gitops_config
  depends_on = [gitops_repo.repo]
}

output "git_credentials" {
  description = "The credentials for the gitops repo(s)"
  value = local.git_credentials
  depends_on = [gitops_repo.repo]
  sensitive = true
}

output "server_name" {
  description = "The name of the cluster that will be configured for gitops"
  value = var.server_name
  depends_on = [gitops_repo.repo]
}

output "sealed_secrets_cert" {
  description = "The certificate used to encrypt sealed secrets"
  value = data.external.cert.result.cert
}
