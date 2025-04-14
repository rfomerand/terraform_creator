# AWS EC2 Instance Terraform Module

This Terraform module deploys an EC2 instance in AWS with the necessary networking components and security configurations. It creates a complete environment including VPC, subnet, security group, and an EC2 instance.

## Infrastructure Components

This module provisions the following AWS resources:
- EC2 Instance
- VPC with Internet Gateway
- Public Subnet
- Route Table with Routes
- Security Group
- SSH Key Pair (if not existing)

## Requirements

- Terraform >= 0.12
- AWS Provider
- AWS CLI configured with appropriate credentials
- SSH key pair (optional - will be created if not specified)

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region for deployment | string | "us-east-1" | no |
| ami_id | AMI ID for EC2 instance | string | "ami-09eb231ad55c3963d" | no |
| instance_type | EC2 instance size | string | "t2.micro" | no |
| instance_name | Name tag for EC2 instance | string | "bigo" | no |
| ssh_key_name | SSH key pair name | string | - | yes |
| environment | Environment tag | string | "production" | no |
| allowed_ssh_ips | CIDR blocks allowed for SSH access | list(string) | ["0.0.0.0/0"] | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_public_ip | Public IP address of the EC2 instance |
| instance_id | ID of the created EC2 instance |
| ssh_command | Command to SSH into the instance |

## Usage Instructions

### Basic Usage

1. Create a new directory and initialize Terraform:
```bash
mkdir terraform-ec2
cd terraform-ec2
terraform init
```

2. Create a `main.tf` file with the following content:
```hcl
module "ec2_instance" {
  source = "./"
  
  ssh_key_name  = "my-key-pair"
  instance_name = "web-server"
}
```

3. Deploy the infrastructure:
```bash
terraform plan
terraform apply
```