variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
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

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c94855ba95c71c99"
}

variable "environment" {
  description = "Environment tag for the EC2 instance"
  type        = string
  default     = "dev"
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
  default     = 1
}