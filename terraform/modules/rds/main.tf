terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
resource "aws_db_subnet_group" "this" {
  name = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier = "postgres-db"
  engine = "postgres"
  engine_version = "14.12"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  db_name = var.db_name
  allocated_storage = 20
  storage_type = "gp2"
  multi_az = true
  skip_final_snapshot = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "postgres-db"
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  vpc_id = var.vpc_id
  description = "Allow DB access from ECS"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

