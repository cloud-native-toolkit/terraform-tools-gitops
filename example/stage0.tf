terraform {
  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
    }
    clis = {
      source = "cloud-native-toolkit/clis"
    }
    gitops = {
      source = "cloud-native-toolkit/gitops"
    }
  }
}
