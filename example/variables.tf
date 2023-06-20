
variable "ibmcloud_api_key" {
  type        = string
  description = "The api key for IBM Cloud access"
}

variable "git_token" {
  type        = string
  description = "Git token"
}

variable "git_username" {
  type        = string
  description = "Git username"
}

variable "git_host" {
  type        = string
}

variable "git_org" {
  default = "seansund"
}

variable "git_repo" {
  default = "git-module-test"
}

variable "gitops_namespace" {
  default = "openshift-gitops"
}

variable "git_project" {
  default = ""
}

variable "server_url" {
}

variable "ingress_subdomain" {
  default = ""
}

variable "login_token" {
  default = ""
}

variable "namespace" {
  default = "gitea"
}

variable "region" {
}

variable "resource_group_name" {
}

variable "cluster_name" {
}

variable "name_prefix" {
}