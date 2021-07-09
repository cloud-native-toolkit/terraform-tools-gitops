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
  description = "A description of my variable"
}

variable "provision" {
  type        = bool
  description = "A description of my variable"
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
