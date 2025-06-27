#output "rds_endpoint" {
  #value = module.rds.rds_endpoint
#}

output "rds_host" {
  description = "RDS endpoint hostname without port"
  value = module.rds.rds_host
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "app_instance_private_ip" {
  value = module.app_instance.private_ips
}

output "load_balancer_dns" {
  value = module.load_balancer.load_balancer_dns
}