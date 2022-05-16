module "gitops" {
  source = "./module"

  host = var.git_host
  type = var.git_type
  org  = ""
  repo = var.git_repo
  token = var.git_token
  username = var.git_username
  gitops_namespace = var.gitops_namespace
  sealed_secrets_cert = module.cert.cert
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource gitops_output {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_repo}' > git_repo"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_token}' > git_token"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.setup_clis.bin_dir}' > .bindir"
  }
}
