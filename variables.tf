variable "host" {
  type        = string
  description = "The host for the git repository. The git host used can be a GitHub, GitHub Enterprise, Gitlab, Bitbucket, Gitea or Azure DevOps server. If the host is null assumes in-cluster Gitea instance will be used."
  default     = ""
}

variable "type" {
  type        = string
  description = "[Deprecated] The type of the hosted git repository."
  default     = ""
}

variable "org" {
  type        = string
  description = "The org/group where the git repository exists/will be provisioned. If the value is left blank then the username org will be used."
  default     = ""
}

variable "project" {
  type        = string
  description = "The project that will be used for the git repo. (Primarily used for Azure DevOps repos)"
  default     = ""
}

variable "username" {
  type        = string
  description = "The username of the user with access to the repository"
  default     = ""
}

variable "token" {
  type        = string
  description = "The personal access token used to access the repository"
  sensitive   = true
  default     = ""
}

variable "gitea_host" {
  type        = string
  description = "The host for the default gitea repository."
  default     = ""
}

variable "gitea_org" {
  type        = string
  description = "The org/group for the default gitea repository. If not provided, the value will default to the username org"
  default     = ""
}

variable "gitea_username" {
  type        = string
  description = "The username of the default gitea repository"
  default     = ""
}

variable "gitea_token" {
  type        = string
  description = "The personal access token used to access the repository"
  sensitive   = true
  default     = ""
}

variable "gitea_ca_cert" {
  type        = string
  description = "The base64 encoded ca certificate of the gitea instance"
  default     = ""
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

variable "strict" {
  type        = bool
  description = "Flag indicating that an error should be thrown if the repo already exists"
  default     = false
}

variable "debug" {
  type        = bool
  description = "Flag indicating that debug loggging should be enabled"
  default     = false
}

variable "ca_cert" {
  type        = string
  description = "(optional) The certificate authority certificate for the self-signed cert used by the git server"
  default     = ""
}

variable "ca_cert_file" {
  type        = string
  description = "(optional) The file containing the certificate authority certificate for the self-signed cert used by the git server"
  default     = ""
}
