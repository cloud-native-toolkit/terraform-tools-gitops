module "gitea" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitea"

  cluster_config_file = module.dev_cluster.config_file_path
  olm_namespace       = module.dev_software_olm.olm_namespace
  operator_namespace  = module.dev_software_olm.target_namespace
  instance_namespace  = module.dev_tools_namespace.name
}
