variable "vpc_cidr" {}

variable "public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
    cidr_block = string
    name         = string
  }))
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    cidr_block = string
    name         = string
  }))
}

variable "azs" {
  description = "List of availability zones"
  type = list(string)
}
