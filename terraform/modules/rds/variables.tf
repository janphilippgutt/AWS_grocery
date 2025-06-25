variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}


variable "db_name" {}
variable "db_user" {}
variable "db_password" {
  sensitive = true
}
