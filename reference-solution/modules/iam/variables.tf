variable "tenant_name" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
