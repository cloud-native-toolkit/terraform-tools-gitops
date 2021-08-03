variable "host" {
  type        = string
  description = "The host for the git repository."
}

variable "type" {
  type        = string
  description = "The type of the hosted git repository (github or gitlab)."
}

variable "org" {
  type        = string
  description = "The org/group where the git repository exists/will be provisioned."
}

variable "repo" {
  type        = string
  description = "The short name of the repository (i.e. the part after the org/group name)"
}

variable "branch" {
  type        = string
  description = "The name of the branch that will be used. If the repo already exists (provision=false) then it is assumed this branch already exists as well"
  default     = "main"
}

variable "provision" {
  type        = bool
  description = "Flag indicating that the git repo should be provisioned. If `false` then the repo is expected to already exist"
  default     = true
}

variable "username" {
  type        = string
  description = "The username of the user with access to the repository"
}

variable "token" {
  type        = string
  description = "The personal access token used to access the repository"
}

variable "public" {
  type        = bool
  description = "Flag indicating that the repo should be public or private"
  default     = false
}

variable "gitops_namespace" {
  type        = string
  description = "The namespace where ArgoCD is running in the cluster"
  default     = "openshift-gitops"
}

variable "banner_label" {
  type        = string
  description = "The label for the cluster"
  default     = "cluster"
}

variable "banner_color" {
  type        = string
  description = "The color for the cluster"
  default     = "purple"
}
