
locals {
  tmp_dir = "${path.cwd}/.tmp/gitops-repo"
  bootstrap_path = "argocd/0-bootstrap/cluster/${var.server_name}"
  cert_file = "${path.cwd}/.tmp/gitops/kubeseal_cert.pem"

  git_default = var.host == "" || var.username == "" || var.token == ""
  tmp_org = local.git_default ? var.gitea_org : var.org

  host = local.git_default ? var.gitea_host : var.host
  org = local.tmp_org != "" ? local.tmp_org : local.username
  username = local.git_default ? var.gitea_username : var.username
  token = local.git_default ? var.gitea_token : var.token

  gitops_config = jsondecode(gitops_repo.repo.gitops_config)
  git_credentials = jsondecode(gitops_repo.repo.git_credentials)
}

resource gitops_repo repo {
  host = local.host
  org  = local.org
  repo = var.repo
  project = var.project
  username = local.username
  token = local.token
  public = var.public
  gitops_namespace = var.gitops_namespace
  sealed_secrets_cert = var.sealed_secrets_cert
  strict = var.strict
}

data clis_check clis {
  clis = ["jq"]
}

data external cert {
  depends_on = [gitops_repo.repo]

  program = ["bash", "${path.module}/scripts/read-cert.sh"]

  query = {
    bin_dir = data.clis_check.clis.bin_dir
    tmp_dir = local.tmp_dir
    repo = gitops_repo.repo.repo
    username = gitops_repo.repo.username
    token = gitops_repo.repo.token
  }
}
