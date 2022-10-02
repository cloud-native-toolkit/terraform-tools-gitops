terraform {
  required_providers {
    gitops = {
      source = "cloud-native-toolkit/gitops"
    }
    clis = {
      source = "cloud-native-toolkit/clis"
    }
  }
}

data clis_check clis {
}

provider gitops {
  bin_dir = data.clis_check.clis.bin_dir

  ca_cert = var.ca_cert_file != "" ? file(var.ca_cert_file) : ""
}
