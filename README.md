# AWS EC2 Instance Terraform Module

This Terraform module provisions an EC2 instance in AWS along with necessary networking components and security configurations.

## Features

- Creates an EC2 instance with Ubuntu AMI
- Sets up a VPC with public subnet
- Configures security group for SSH access
- Generates new SSH key pair
- Applies 'bigo' tag to instance

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 0.12 or later)
- SSH key pair generation capability

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Create an SSH key pair:
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/YOUR_KEY_NAME
```

3. Apply the configuration:
```bash
terraform apply
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region | string | "us-east-1" | no |
| instance_type | EC2 instance type | string | "t2.micro" | no |
| ami_id | Ubuntu AMI ID | string | "ami-0c7217cdde317cfec" | no |
| key_name | SSH key pair name | string | n/a | yes |
| instance_name | Instance name tag | string | "bigo" | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_public_ip | Public IP address |
| instance_private_ip | Private IP address |
| instance_public_dns | Public DNS name |
| ssh_command | SSH connection command |

## Security

- Security group allows inbound SSH (port 22)
- Use SSH key pair for authentication
- VPC provides network isolation

## Network Configuration

- VPC CIDR: 10.0.0.0/16
- Public Subnet CIDR: 10.0.1.0/24
- Internet Gateway for public internet access