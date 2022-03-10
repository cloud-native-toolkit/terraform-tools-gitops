
locals {
  bin_dir = module.setup_clis.bin_dir
  bootstrap_path = "argocd/0-bootstrap/cluster/${var.server_name}"
  cert_file = "${path.cwd}/.tmp/gitops/kubeseal_cert.pem"
  gitops_config = {
    boostrap = {
      argocd-config = {
        project = "0-bootstrap"
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

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

module "gitops-repo" {
  source = "github.com/cloud-native-toolkit/terraform-tools-git-repo.git?ref=v1.6.1"

  host  = var.host
  type  = var.type
  org   = var.org
  repo  = var.repo
  token = var.token
  branch = var.branch
  public = var.public
  strict = var.strict
}

resource null_resource initialize_gitops {
  count = var.provision || var.initialize ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/scripts/initialize-gitops.sh '${module.gitops-repo.repo}' '${var.gitops_namespace}' '${var.server_name}'"

    environment = {
      TOKEN = nonsensitive(module.gitops-repo.token)
      CONFIG = yamlencode(local.gitops_config)
      CERT = var.sealed_secrets_cert
      BIN_DIR = local.bin_dir
    }
  }
}

data external cert {
  depends_on = [null_resource.initialize_gitops]

  program = ["bash", "${path.module}/scripts/read-cert.sh"]

  query = {
    bin_dir = module.setup_clis.bin_dir
    repo = module.gitops-repo.repo
    token = module.gitops-repo.token
  }
}
