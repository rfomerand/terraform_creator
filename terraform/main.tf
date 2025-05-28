terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.instance_name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = var.tags
}

# Security group for SSH access
resource "aws_security_group" "ssh_access" {
  name        = "${var.instance_name}-ssh-sg"
  description = "Security group for SSH access"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.instance_name}-ssh-sg"
  })
}

# EC2 instance
resource "aws_instance" "vm" {
  ami           = var.ami_id
  instance_type = var.instance_type

  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 50
    encrypted   = true

    tags = merge(var.tags, {
      Name = "${var.instance_name}-root-volume"
    })
  }

  tags = merge(var.tags, {
    Name        = var.instance_name
    Environment = var.environment
  })
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.instance_name}-key.pem"
  file_permission = "0600"
}