resource "aws_instance" "this" {
  for_each = {
    for inst in var.instances :
    inst.name => inst
  }

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  key_name               = each.value.key_name

  tags = merge(
    {
      Name = each.value.name
    },
    each.value.tags
  )
}
