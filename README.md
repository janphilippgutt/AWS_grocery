state: July 08, 2025

# 🏗️ GroceryMate Infrastructure (AWS + Terraform)

**Note:** This repository is a fork of the Flask-based GroceryMate application, originally provided by Masterschool for learning purposes. 
The original application code and its standalone APP_README can be found in the root directory of this project. My fork documents the infrastructure I built for the application — a fully functional, modular AWS environment provisioned with Terraform.

## Key Features

**Modular Infrastructure**

Each AWS component is defined as a reusable Terraform module, making the setup clean, extensible, and easy to manage.

**High Availability**

The application runs in Docker containers behind an Application Load Balancer (ALB), with multiple EC2 instances across availability zones.

**Automated RDS Setup**

A PostgreSQL RDS instance is provisioned in a private subnet, with automated database creation and initial population handled by Terraform.

**S3 Bucket Integration**

The app interacts with a private S3 bucket, which is:

- Created automatically in the same region as the EC2 instances

- Provisioned with a default avatar image at launch

**Secure Access via Bastion Host**

A bastion host is deployed for secure SSH access to private resources.

**Customizable IAM Policies**

An integrated IAM module provides fine-grained access control and lets you customize permissions for each component.

## Developer Focus

Environment Variables like S3 credentials and DB connection strings are injected at runtime.

All modules are called from root/main.tf using tailored inputs.



✅ The infrastructure has been tested and is fully functional.


---

## 📐 Architecture Overview

<img width="820" height="756" alt="Image" src="https://github.com/user-attachments/assets/9ab468c7-7fc5-45ad-baa0-bef368fecc9c" />

**Note: Designed for learning and testing: EC2 instances are currently deployed in a public subnet, but the setup can easily be adapted for production with private subnets and NAT Gateway support.**


---

## 🧱 Infrastructure Components

This project uses a modular Terraform setup. Each infrastructure component is managed through a reusable module, instantiated with project-specific inputs in main.tf.

| Component                | Description                                                             |
| ------------------------ | ----------------------------------------------------------------------- |
| `vpc` module             | Custom VPC with public/private subnets across 2 AZs                     |
| `app_instance` module    | Two EC2 instances running the app in Docker containers (with S3 access) |
| `alb` module             | Application Load Balancer routing HTTP traffic across EC2s              |
| `rds` module             | PostgreSQL database deployed in private subnets                         |
| `bastion` module         | Bastion host (jump box) for secure SSH into private resources           |
| `security_groups` module | Access control for traffic between components (e.g., EC2 <-> RDS)       |
| `s3_bucket` module       | S3 bucket with private access, versioning, and default avatar upload    |
| `iam` module             | IAM role + instance profile granting EC2 permission to access S3        |


---

## 📂 Modules Structure

    .
    ├── main.tf

    ├── modules/

    │   ├── vpc/
    │   ├── bastion/
    │   ├── app_instance/
    │   ├── rds/
    │   ├── security_group/
    │   └── load_balancer/
    │   ├── iam/
    │   └── s3/


## 🚀 How to Deploy

### 1. Clone the repository
```bash
git clone https://github.com/janphilippgutt/AWS_grocery.git
cd terraform
```

### 2. Configure your variables

Create terraform.tfvars and set the required variables:

```bash
key_name        = "your-ec2-keypair-name" # A key pair name existing in your account for default region eu-central-1
app_repo_url    = "https://github.com/janphilippgutt/AWS_grocery.git"
db_name         = "grocerymate_db" # Or other name to your liking
db_user         = "grocery_user" # Or other name to your liking
db_password     = "yourStrongPassword" # Enter a custom password
jwt_secret_key  = "superSecretKey" # Create and set a jwt key
my_ip           = "YOUR.IP.ADDRESS/32" # IP address of your machine. Find out with 'curl -4 ifconfig.me' 

```

### 3. Initialize and apply

```bash
terraform init
terraform plan
terraform apply
```

## 🔐 Access & Testing

    App URL: Find your Load Balancer DNS in the AWS Console under EC2 > Load Balancers

    Health Check: http://<ALB-DNS>/health

    SSH: When deploying in private subnets, connect to EC2s via the bastion using SSH agent forwarding

## 🛠️ Next Steps

Integrate Auto Scaling Group

Add CloudWatch logs and metrics

Define dev and prod environments

## 📄 License

Under the MIT License 