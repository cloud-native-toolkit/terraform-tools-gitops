
output "config_host" {
  value = module.gitops-repo.host
  description = "The host name of the bootstrap git repo"
  depends_on = [null_resource.initialize_gitops]
}

output "config_org" {
  value = module.gitops-repo.org
  description = "The org name of the bootstrap git repo"
  depends_on = [null_resource.initialize_gitops]
}

output "config_name" {
  value = module.gitops-repo.name
  description = "The repo name of the bootstrap git repo"
  depends_on = [null_resource.initialize_gitops]
}

output "config_project" {
  value = module.gitops-repo.project
  description = "The project name of the bootstrap git repo (for Azure DevOps)"
  depends_on = [null_resource.initialize_gitops]
}

output "config_repo" {
  value = module.gitops-repo.repo
  description = "The repo that contains the argocd configuration"
  depends_on = [null_resource.initialize_gitops]
}

output "config_repo_url" {
  value = module.gitops-repo.url
  description = "The repo that contains the argocd configuration"
  depends_on = [null_resource.initialize_gitops]
}

output "config_username" {
  value       = module.gitops-repo.username
  description = "The username for the config repo"
  depends_on = [null_resource.initialize_gitops]
}

output "config_token" {
  value       = module.gitops-repo.token
  description = "The token for the config repo"
  sensitive   = true
  depends_on  = [null_resource.initialize_gitops]
}

output "config_paths" {
  description = "The paths in the config repo"
  value = {
    infrastructure = "argocd/1-infrastructure"
    services       = "argocd/2-services"
    applications   = "argocd/3-applications"
  }
  depends_on = [null_resource.initialize_gitops]
}

output "config_projects" {
  description = "The ArgoCD projects for the different layers of the repo"
  value = {
    infrastructure = "1-infrastructure"
    services       = "2-services"
    applications   = "3-applications"
  }
  depends_on = [null_resource.initialize_gitops]
}

output "bootstrap_path" {
  description = "The path to the bootstrap configuration"
  value       = local.bootstrap_path
  depends_on = [null_resource.initialize_gitops]
}

output "bootstrap_branch" {
  description = "The branch in the gitrepo containing the bootstrap configuration"
  value       = module.gitops-repo.branch
  depends_on = [null_resource.initialize_gitops]
}

output "application_repo" {
  value = module.gitops-repo.repo
  description = "The repo that contains the application configuration"
  depends_on = [null_resource.initialize_gitops]
}

output "application_repo_url" {
  value = module.gitops-repo.url
  description = "The repo that contains the application configuration"
  depends_on = [null_resource.initialize_gitops]
}

output "application_username" {
  value       = module.gitops-repo.username
  description = "The username for the application repo"
  depends_on = [null_resource.initialize_gitops]
}

output "application_token" {
  value       = module.gitops-repo.token
  description = "The token for the application repo"
  depends_on  = [null_resource.initialize_gitops]
  sensitive   = true
}

output "application_paths" {
  description = "The paths in the application repo"
  value = {
    infrastructure = "payload/1-infrastructure"
    services       = "payload/2-services"
    applications   = "payload/3-applications"
  }
  depends_on = [null_resource.initialize_gitops]
}

output "gitops_config" {
  description = "Config information regarding the gitops repo structure"
  value = local.gitops_config
  depends_on = [null_resource.initialize_gitops]
}

output "git_credentials" {
  description = "The credentials for the gitops repo(s)"
  value = local.git_credentials
  depends_on = [null_resource.initialize_gitops]
  sensitive = true
}

output "server_name" {
  description = "The name of the cluster that will be configured for gitops"
  value = var.server_name
  depends_on = [null_resource.initialize_gitops]
}

output "sealed_secrets_cert" {
  description = "The certificate used to encrypt sealed secrets"
  value = data.external.cert.result.cert
}
