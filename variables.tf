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

variable "initialize" {
  type        = bool
  description = "Flag indicating that the git repo should be initialized. If `false` then the repo is expected to already have been initialized"
  default     = false
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

variable "server_name" {
  type        = string
  description = "The name of the cluster that will be configured via gitops. This is used to separate the config by cluster"
  default     = "default"
}

variable "sealed_secrets_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}
