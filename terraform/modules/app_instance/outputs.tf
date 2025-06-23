output "instance_ids" {
  value = [for i in aws_instance.this : i.id]
}
