
module "gitops-repo" {
  source = "github.com/cloud-native-toolkit/terraform-tools-git-repo.git?ref=v1.2.1"

  host  = var.host
  type  = var.type
  org   = var.org
  repo  = var.repo
  token = var.token
}

resource null_resource initialize_gitops {

  provisioner "local-exec" {
    command = "${path.module}/scripts/initialize-gitops.sh '${module.gitops-repo.repo}' '${var.gitops_namespace}'"

    environment = {
      TOKEN = module.gitops-repo.token
    }
  }
}
