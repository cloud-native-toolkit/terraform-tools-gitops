module "gitops" {
  source = "../"

  host = var.git_host
  org  = ""
  repo = var.git_repo
  username = var.git_username
  token = var.git_token
  project = var.git_project
  gitops_namespace = var.gitops_namespace
  sealed_secrets_cert = module.cert.cert
  strict = true
  debug = true
}

resource null_resource gitops_output {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_repo}' > git_repo"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_username}' > git_username"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_token}' > git_token"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.sealed_secrets_cert}' > sealed_secrets_cert"
  }

  provisioner "local-exec" {
    command = "echo -n '${data.clis_check.clis.bin_dir}' > .bindir"
  }
}
