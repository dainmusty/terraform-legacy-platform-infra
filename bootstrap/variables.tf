variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "trainee_name" {
  description = "Your GitLab username or first name. Used to namespace your state bucket/table."
  type        = string
}
