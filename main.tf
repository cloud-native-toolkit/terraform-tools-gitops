
locals {
  tmp_dir = "${path.cwd}/.tmp/gitops-repo"
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
    username = module.gitops-repo.username
    token = module.gitops-repo.token
  }]

  git_default = var.host == "" || var.username == "" || var.token == ""
  tmp_org = local.git_default ? var.gitea_org : var.org

  host = local.git_default ? var.gitea_host : var.host
  org = local.tmp_org != "" ? local.tmp_org : local.username
  username = local.git_default ? var.gitea_username : var.username
  token = local.git_default ? var.gitea_token : var.token
}

module setup_clis {
  source = "cloud-native-toolkit/clis/util"
  version = "1.16.3"
}

module "gitops-repo" {
  source = "github.com/cloud-native-toolkit/terraform-tools-git-repo.git?ref=v2.1.3"

  host  = local.host
  org   = local.org
  repo  = var.repo
  project = var.project
  username = local.username
  token = local.token
  public = var.public
  strict = var.strict
}

resource null_resource initialize_gitops {
  provisioner "local-exec" {
    command = "${path.module}/scripts/initialize-gitops.sh '${module.gitops-repo.repo}' '${var.gitops_namespace}' '${var.server_name}'"

    environment = {
      USERNAME = module.gitops-repo.username
      TOKEN = nonsensitive(module.gitops-repo.token)
      CONFIG = yamlencode(local.gitops_config)
      CERT = var.sealed_secrets_cert
      BIN_DIR = local.bin_dir
      TMP_DIR = local.tmp_dir
    }
  }
}

data external cert {
  depends_on = [null_resource.initialize_gitops]

  program = ["bash", "${path.module}/scripts/read-cert.sh"]

  query = {
    bin_dir = module.setup_clis.bin_dir
    tmp_dir = local.tmp_dir
    repo = module.gitops-repo.repo
    username = module.gitops-repo.username
    token = module.gitops-repo.token
  }
}
