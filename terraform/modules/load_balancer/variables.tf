
# These declare input variables the module needs. They don’t define values — they define the shape of the data the module expects.
# Think of them like function parameters.

variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}

variable "instance_map" {
  description = "Map of instances names to instance IDs"
  type = map(string)
}

# Without ALB:
#variable "instance_ids" {
#  type = list(string)
#}