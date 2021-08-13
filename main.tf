
locals {
  bootstrap_path = "argocd/0-bootstrap/cluster/${var.server_name}"
  gitops_config = {
    boostrap = {
      argocd-config = {
        project = "bootstrap"
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "argocd/0-bootstrap"
      }
    }
    infrastructure = {
      argocd-config = {
        project = "1-infrastructure"
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "argocd/1-infrastructure"
      }
      payload = {
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "payload/1-infrastructure"
      }
    }
    services = {
      argocd-config = {
        project = "2-services"
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "argocd/2-services"
      }
      payload = {
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "payload/2-services"
      }
    }
    applications = {
      argocd-config = {
        project = "3-applications"
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "argocd/3-applications"
      }
      payload = {
        repo = module.gitops-repo.repo
        url = module.gitops-repo.url
        path = "payload/3-applications"
      }
    }
  }
  git_credentials = [{
    repo = module.gitops-repo.repo
    url = module.gitops-repo.url
    username = var.username
    token = var.token
  }]
}

module "gitops-repo" {
  source = "github.com/cloud-native-toolkit/terraform-tools-git-repo.git?ref=v1.3.0"

  host  = var.host
  type  = var.type
  org   = var.org
  repo  = var.repo
  token = var.token
  branch = var.branch
}

resource null_resource initialize_gitops {

  provisioner "local-exec" {
    command = "${path.module}/scripts/initialize-gitops.sh '${module.gitops-repo.repo}' '${var.gitops_namespace}' '${var.server_name}' '${var.banner_label}' '${var.banner_color}'"

    environment = {
      TOKEN = module.gitops-repo.token
      CONFIG = yamlencode(local.gitops_config)
    }
  }
}
