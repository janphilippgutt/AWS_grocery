

# The full RDS endpoint, including hostname and port.
# Example: postgres-db.xxxxxx.eu-central-1.rds.amazonaws.com:5432
#output "rds_endpoint" {
 # value = aws_db_instance.this.endpoint
#}


# The RDS hostname without port, for use in .env files or tools that expect the host only.
# If we inject the full endpoint (with :5432) into POSTGRES_HOST, it will break tools like psql and Sequelize,
# which expect the host and port separately.
output "rds_host" {
  description = "RDS endpoint hostname without port"
  value       = split(":", aws_db_instance.this.endpoint)[0]
}


output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}