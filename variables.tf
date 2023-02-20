variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_user" {
  type = string
}

variable "gcp_project" {
  type = string
}

variable "compilation_result_name" {
  type    = string
  default = "NONE"
}
