variable "bucket" {
  description = "Name of S3 bucket"
  type = string
}

variable "tags" {
  description = "Tags for S3 bucket"
  type = map(string)
  default = {}
}