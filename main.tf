
locals {
  tmp_dir = "${path.cwd}/.tmp/gitops-repo"
  bin_dir = data.clis_check.clis.bin_dir
  bootstrap_path = "argocd/0-bootstrap/cluster/${var.server_name}"

  gitops_config = jsondecode(data.external.git_config.result.config)
  git_credentials = jsondecode(data.external.git_config.result.credentials)

  git_default = var.host == "" || var.username == "" || var.token == ""
  tmp_org = local.git_default ? var.gitea_org : var.org

  host = local.git_default ? var.gitea_host : var.host
  org = local.tmp_org != "" ? local.tmp_org : local.username
  username = local.git_default ? var.gitea_username : var.username
  token = local.git_default ? var.gitea_token : var.token
  branch = var.branch != "" ? var.branch : "main"

  ca_cert = var.ca_cert_file != "" ? file(var.ca_cert_file) : var.ca_cert
}

data clis_check clis {
  clis = ["igc", "jq"]
}

resource random_string module_id {
  length = 16
}

resource null_resource initialize_gitops {
  triggers = {
    host = local.host
    org = local.org
    project = var.project
    repo = var.repo
    username = local.username
    token = local.token
    ca_cert = local.ca_cert
    sealed_secrets_cert = var.sealed_secrets_cert
    tmp_dir = local.tmp_dir
    bin_dir = local.bin_dir
    module_id = random_string.module_id.result
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-init '${self.triggers.repo}' --moduleId '${self.triggers.module_id}' --tmpDir '${self.triggers.tmp_dir}' --strict='${var.strict}' --debug"

    environment = {
      GIT_HOST = self.triggers.host
      GIT_ORG = self.triggers.org
      GIT_PROJECT = self.triggers.project
      GIT_USERNAME = self.triggers.username
      GIT_TOKEN = nonsensitive(self.triggers.token)
      CA_CERT = self.triggers.ca_cert
      KUBESEAL_CERT = self.triggers.sealed_secrets_cert
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-init '${self.triggers.repo}' --delete --moduleId '${self.triggers.module_id}' --tmpDir '${self.triggers.tmp_dir}' --debug"

    environment = {
      GIT_HOST = self.triggers.host
      GIT_ORG = self.triggers.org
      GIT_PROJECT = self.triggers.project
      GIT_USERNAME = self.triggers.username
      GIT_TOKEN = nonsensitive(self.triggers.token)
      CA_CERT = self.triggers.ca_cert
      KUBESEAL_CERT = self.triggers.sealed_secrets_cert
    }
  }
}

data external git_config {
  program = ["bash", "${path.module}/scripts/get-gitops-config.sh"]

  query = {
    bin_dir = local.bin_dir
    host = local.host
    org = local.org
    project = var.project
    repo = var.repo
    username = local.username
    token = local.token
    ca_cert = base64encode(local.ca_cert)
    tmp_dir = local.tmp_dir
  }
}
