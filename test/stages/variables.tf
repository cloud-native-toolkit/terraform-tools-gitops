
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
  default     = "github.com"
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
