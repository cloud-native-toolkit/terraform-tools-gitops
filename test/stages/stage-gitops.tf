module "gitops" {
  source = "./module"

  host = "github.com"
  type = "github"
  org  = "seansund"
  repo = "git-module-test"
  token = var.git_token
  gitops_namespace = "openshift-gitops"
}

resource null_resource gitops_output {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_repo}' > git_repo"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_token}' > git_token"
  }
}
