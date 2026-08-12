variable "tenant_name" {
  type = string
}

variable "bucket_name_prefix" {
  type    = string
  default = "wandaprep"
}

variable "tags" {
  type    = map(string)
  default = {}
}
