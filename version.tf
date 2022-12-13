terraform {
  required_version = ">= 0.15.0"

  required_providers {
    gitops = {
      source = "cloud-native-toolkit/gitops"
      version = ">= 0.12.0"
    }
    clis = {
      source = "cloud-native-toolkit/clis"
      version = ">= 0.2.0"
    }
  }
}
