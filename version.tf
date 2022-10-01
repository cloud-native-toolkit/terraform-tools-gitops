terraform {
  required_version = ">= 0.15.0"

  required_providers {
    clis = {
      source = "cloud-native-toolkit/clis"
      version = ">= 0.1.0"
    }
  }
}
