

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]  # Canonical (Ubuntu publisher)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# Get a list of (at least two) AZs in the defined region (keep config portable)
data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr

  # Limit to first 2 AZs for simplicity; adapt if you want more
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = [
    {
      cidr_block = "10.0.1.0/24"
      name       = "public-subnet-1"
    },
    {
      cidr_block = "10.0.2.0/24"
      name       = "public-subnet-2"
    }
  ]

  private_subnets = [
    {
      cidr_block = "10.0.10.0/24"
      name       = "private-app-subnet-1"
    },
    {
      cidr_block = "10.0.11.0/24"
      name       = "private-app-subnet-2"
    },
    {
      cidr_block = "10.0.20.0/24"
      name       = "private-db-subnet-1"
    },
    {
      cidr_block = "10.0.21.0/24"
      name       = "private-db-subnet-2"
    }
  ]
}

# In public subnet, to ssh into it from local machine
module "bastion" {
  source             = "./modules/bastion"
  ami                = data.aws_ami.ubuntu.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.bastion_sg.security_group_id]
  key_name           = var.key_name
  tags = {name = "bastion-host"}
}

# Render a .env file for the Flask application running on EC2
# This uses a template file (user_data.env.tpl) with placeholders like ${db_user}, ${s3_bucket_name}, etc.
# The output will be passed into the EC2 instance as part of user_data.sh.tpl

data "template_file" "env_file" {
  # Path to the environment template. Reads the .env structure from the template file
  template = file("${path.module}/modules/app_instance/user_data.env.tpl")
  # These variables will replace the placeholders in the .tpl file
  vars = {
    jwt_secret_key  = var.jwt_secret_key
    db_user         = var.db_user
    db_password     = var.db_password
    db_name         = var.db_name
    db_host         = module.rds.rds_host # only hostname, not full URI
    db_uri          = "postgresql://${var.db_user}:${var.db_password}@${module.rds.rds_host}:5432/${var.db_name}"

    # S3 config (used by app to upload avatar images)
    s3_bucket_name  = module.s3_bucket.bucket_name # output from s3 module
    s3_region       = var.region # declared in root variables.tf
  }
}


module "app_instance" {
  source = "./modules/app_instance"

  instances = [
    {
      name               = "grocerymate-app-1"
      ami                = data.aws_ami.ubuntu.id
      instance_type      = "t3.micro"
      subnet_id          = module.vpc.public_subnet_ids[0]
      security_group_ids = [module.public_ec2_sg.security_group_id]
      key_name           = var.key_name
      tags               = {name = "instance-1"}
      docker_port        = 5000
    },
    {
      name               = "grocerymate-app-2"
      ami                = data.aws_ami.ubuntu.id
      instance_type      = "t3.micro"
      subnet_id          = module.vpc.public_subnet_ids[1]
      security_group_ids = [module.public_ec2_sg.security_group_id]
      key_name           = var.key_name
      tags               = {name = "instance-2"}
      docker_port        = 5000
    }
  ]

  app_repo_url = var.app_repo_url

  # The rendered string output, which gets passed into the EC2 user_data
  env_file_content  = data.template_file.env_file.rendered
  db_host            = module.rds.rds_host # Must use rds_host (without port) for compatibility with Docker env vars and database clients
  db_name            = var.db_name
  db_password        = var.db_password
  db_user            = var.db_user
  jwt_secret         = var.jwt_secret_key

  # Use the instance profile name created inside module.ec2_iam when launching this EC2
  iam_instance_profile = module.ec2_iam.instance_profile_name # "instance_profile_name" being an output from  modules/iam/outputs.tf
  s3_bucket_name = module.s3_bucket.bucket_name
  s3_region = var.region
}

module "bastion_sg" {
  source     = "./modules/security_group"
  name       = "bastion-sg"
  description = "Allow SSH from my IP"
  vpc_id     = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "bastion-sg"
  }
}

module "private_ec2_sg" {
  source     = "./modules/security_group"
  name       = "private-ec2-sg"
  description = "Allow SSH from bastion and ALB to reach EC2s on port 5000"
  vpc_id     = module.vpc.vpc_id

  ingress_rules = [
    {
      description     = "SSH from bastion"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [module.bastion_sg.security_group_id]
    },
    {
      description = "Allow from ALB on port 5000"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      security_groups = [module.load_balancer.load_balancer_sg_id]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "private-ec2-sg"
  }
}

module "public_ec2_sg" {
  source     = "./modules/security_group"
  name       = "public-ec2-sg"
  description = "Allow SSH from my IP and ALB app on port 5000"
  vpc_id     = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "SSH from my IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    },
    {
      description = "Allow from ALB on port 5000"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      security_groups = [module.load_balancer.load_balancer_sg_id]
      # cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "public-ec2-sg"
  }
}


module "rds" {
  source = "./modules/rds"
  db_name = var.db_name
  db_user = var.db_user
  db_password = var.db_password

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}

module "load_balancer" {
  source = "./modules/load_balancer"
  vpc_id = module.vpc.vpc_id # exposed in/ coming from modules/vpc/outputs.tf
  public_subnets = module.vpc.public_subnet_ids ## exposed in/ coming from modules/vpc/outputs.tf
  # instance_ids = module.app_instance.instance_ids
  # Send a map instead, to take into account the instance ids are not know yet:
  instance_map = {
    "app1" = module.app_instance.instance_ids[0]
    "app2" = module.app_instance.instance_ids[1]
  }
}

module "ec2_iam" {
  source      = "./modules/iam"
  role_name   = "grocerymate-ec2-role"
  policy_name = "grocerymate-policy"

  policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*" # Logs from this EC2 can be sent to any log group
      },
      {
        Effect = "Allow",
        Action = [
        "S3:PutObject",
        "S3:GetObject",
        "S3:ListBucket"
        ],
        Resource = [
        module.s3_bucket.bucket_arn,
        "${module.s3_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "ec2-iam-role"
  }
}

module "s3_bucket" {
  source = "./modules/s3"

  bucket = "grocerymate-avatars-${random_id.bucket_suffix.hex}"
  tags = {
    Name = "avatars-bucket"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "null_resource" "upload_default_avatar" {
  depends_on = [module.s3_bucket]

  provisioner "local-exec" {
    command = "aws s3 cp ../backend/avatar/user_default.png s3://${module.s3_bucket.bucket_name}/avatars/user_default.png --region ${var.region}"
    }
  }

