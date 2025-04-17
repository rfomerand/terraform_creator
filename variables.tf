variable "region" {
  description = "AWS region for resource deployment"
  type        = string 
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "bigo"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}