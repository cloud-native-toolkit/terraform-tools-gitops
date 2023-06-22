module "gitea" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitea"

  cluster_config_file = module.cluster.config_file_path
  instance_namespace  = module.dev_tools_namespace.name
  ingress_subdomain   = module.cluster.platform.ingress
  tls_secret_name     = module.cluster.platform.tls_secret
  preserve_volumes    = false
}
