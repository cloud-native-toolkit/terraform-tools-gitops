module "cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-cluster-login.git"

  resource_group_name = var.resource_group_name
  region = var.region
  name = var.cluster_name
}

resource null_resource output_kubeconfig {
  provisioner "local-exec" {
    command = "echo '${module.cluster.platform.kubeconfig}' > .kubeconfig"
  }
}

resource null_resource output_cluster_type {
  provisioner "local-exec" {
    command = "echo '${module.cluster.platform.type_code}' > .cluster_type"
  }
}
