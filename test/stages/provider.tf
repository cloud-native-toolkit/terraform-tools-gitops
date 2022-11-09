provider "gitops" {
  username = var.git_username
  token = var.git_token
  bin_dir  = data.clis_check.clis.bin_dir
}

data clis_check clis {
  clis = ["yq", "jq", "gitu"]
}
