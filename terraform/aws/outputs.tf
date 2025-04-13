output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example_instance.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.example_instance.public_ip}"
}