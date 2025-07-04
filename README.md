state: July 04, 2025

# 🏗️ GroceryMate Infrastructure (AWS + Terraform)

**Note:** This repository is a fork of the Flask-based GroceryMate application, originally provided by Masterschool for learning purposes. 
The original application code and its standalone APP_README can be found in the root directory of this project.

This fork documents the infrastructure I built for the application: A fully functional, **modular AWS infrastructure** provisioned with **Terraform**. 
It sets up a **highly available environment** that runs the application **dockerized** behind an **Application Load Balancer (ALB)**, backed by a **PostgreSQL RDS database** and secured via a **bastion host** for administrative access.
The app interacts with a **S3 Bucket** that is **automatically provisioned** with a default image uploaded from the repo at launch.  
An integrated **IAM module** helps **customize policies as required**. 

In this setup, **database creation and initial population are fully automated** using Terraform. A key focus of this project is designing each infrastructure component as a reusable module. These modules are invoked from ```root/main.tf``` with custom values, making the infrastructure highly adaptable and easy to extend.

The provided infrastructure has been tested for full functionality. Additional features—such as autoscaling and environment separation—are planned and will be added soon.

---

## 📐 Architecture Overview

- Diagram to be added 

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