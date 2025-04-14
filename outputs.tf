output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2_instance.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i <path-to-private-key> ubuntu@${aws_instance.ec2_instance.public_dns}"
}