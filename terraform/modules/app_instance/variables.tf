variable "instances" {
  description = "List of EC2 instances to create"
  type = list(object({
    name               = string
    ami                = string
    instance_type      = string
    subnet_id          = string
    security_group_ids = list(string)
    key_name           = string
    tags               = optional(map(string), {})
  }))
}
