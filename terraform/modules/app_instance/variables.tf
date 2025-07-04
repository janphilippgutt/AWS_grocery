variable "instances" {
  description = "List of app instances"
  type = list(object({
    name               = string
    ami                = string
    instance_type      = string
    subnet_id          = string
    security_group_ids = list(string)
    key_name           = string
    docker_port        = number
    tags               = map(string)
  }))
}

variable "app_repo_url" {
  description = "GitHub repo URL for the Docker app"
  type        = string
  default     = "https://github.com/janphilippgutt/AWS_grocery.git"
}

variable "env_file_content" {
  description = "Rendered content of the .env file"
  type        = string
}


variable "db_user" {}
variable "db_password" {}
variable "jwt_secret" {}
variable "db_name" {}
variable "db_host" {}

variable "s3_bucket_name" {
  description = "Name of S3 bucket for app"
  type        = string
}

variable "s3_region" {
  description = "Region of S3 bucket"
  type        = string
}


variable "iam_instance_profile" {
  description = "IAM instance profile to attach"
  type = string
}