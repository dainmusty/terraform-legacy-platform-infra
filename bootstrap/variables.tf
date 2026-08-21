variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "trainee_name" {
  description = "Your GitLab username or first name. Used to namespace your state bucket/table."
  type        = string
   
}
