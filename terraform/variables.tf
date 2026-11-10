variable "aws_region" {}
variable "instance_type" {}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}