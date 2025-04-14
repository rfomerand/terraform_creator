output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.ec2_instance.instance_state
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.ec2_instance.arn
}