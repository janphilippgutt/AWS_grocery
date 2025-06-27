output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
  description = "The DNS name of the public load balancer"
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}