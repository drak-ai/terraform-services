variable "env" {}
variable "app" {}
variable "region" {}
variable "profile" {}
variable "product" {}
variable "remote_state_bucket" {}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Map of tags that are added to the supported AWS resources."
}

variable "domain" {
  type        = string
  default     = ""
  description = "Domain name that will be used as S3 static website bucket name."
}

variable "cloudflare_api_token" {
  sensitive = true
  default   = ""
}

variable "cloudflare_account_id" {
  default = "67dc3d0717dbceec64e41405ea196760"
}
