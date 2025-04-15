variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c94855ba95c71c99"  # Amazon Linux 2 AMI in us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "example-instance"
}

variable "environment" {
  description = "Environment tag for resource management"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}