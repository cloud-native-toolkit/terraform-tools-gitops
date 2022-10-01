
locals {
  tmp_dir = "${path.cwd}/.tmp/gitops-repo"
  bin_dir = data.clis_check.clis.bin_dir
  bootstrap_path = "argocd/0-bootstrap/cluster/${var.server_name}"

  url = data.external.git_config.result.url
  repo = data.external.git_config.result.repo
  gitops_config_int = jsondecode(data.external.git_config.result.config)
  gitops_config = {
    bootstrap = {
      argocd-config = {
        project = local.gitops_config_int["bootstrap"]["argocd-config"]["project"]
        repo = local.gitops_config_int["bootstrap"]["argocd-config"]["repo"]
        url = local.gitops_config_int["bootstrap"]["argocd-config"]["url"]
        path = local.gitops_config_int["bootstrap"]["argocd-config"]["path"]
      }
    }
    infrastructure = {
      argocd-config = {
        project = local.gitops_config_int["infrastructure"]["argocd-config"]["project"]
        repo = local.gitops_config_int["infrastructure"]["argocd-config"]["repo"]
        url = local.gitops_config_int["infrastructure"]["argocd-config"]["url"]
        path = local.gitops_config_int["infrastructure"]["argocd-config"]["path"]
      }
      payload = {
        repo = local.gitops_config_int["infrastructure"]["payload"]["repo"]
        url = local.gitops_config_int["infrastructure"]["payload"]["url"]
        path = local.gitops_config_int["infrastructure"]["payload"]["path"]
      }
    }
    services = {
      argocd-config = {
        project = local.gitops_config_int["services"]["argocd-config"]["project"]
        repo = local.gitops_config_int["services"]["argocd-config"]["repo"]
        url = local.gitops_config_int["services"]["argocd-config"]["url"]
        path = local.gitops_config_int["services"]["argocd-config"]["path"]
      }
      payload = {
        repo = local.gitops_config_int["services"]["payload"]["repo"]
        url = local.gitops_config_int["services"]["payload"]["url"]
        path = local.gitops_config_int["services"]["payload"]["path"]
      }
    }
    applications = {
      argocd-config = {
        project = local.gitops_config_int["applications"]["argocd-config"]["project"]
        repo = local.gitops_config_int["applications"]["argocd-config"]["repo"]
        url = local.gitops_config_int["applications"]["argocd-config"]["url"]
        path = local.gitops_config_int["applications"]["argocd-config"]["path"]
      }
      payload = {
        repo = local.gitops_config_int["applications"]["payload"]["repo"]
        url = local.gitops_config_int["applications"]["payload"]["url"]
        path = local.gitops_config_int["applications"]["payload"]["path"]
      }
    }
  }
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
    command = "${self.triggers.bin_dir}/igc gitops-init '${self.triggers.repo}' --moduleId '${self.triggers.module_id}' --tmpDir '${self.triggers.tmp_dir}' --strict='${var.strict}' --output json --debug"

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
    command = "${self.triggers.bin_dir}/igc gitops-init '${self.triggers.repo}' --delete --moduleId '${self.triggers.module_id}' --tmpDir '${self.triggers.tmp_dir}' --output json --debug"

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
  depends_on = [null_resource.initialize_gitops]

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

resource null_resource print_config {
  provisioner "local-exec" {
    command = "echo 'Config: ${data.external.git_config.result.config}'"
  }
  provisioner "local-exec" {
    command = "echo 'Credentials: ${data.external.git_config.result.credentials}'"
  }
}
