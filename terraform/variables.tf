variable "region" {
  type = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "key_name" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "jwt_secret_key" {
  type = string
}

variable "app_repo_url" {
  description = "Repo to clone into the EC2 instance"
  type        = string
  default     = "https://github.com/janphilippgutt/AWS_grocery.git"
}
