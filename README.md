# Terraform AWS EC2 Instance Module

This Terraform module deploys an AWS EC2 instance with associated networking and security configurations. The module provides a straightforward way to provision and manage an EC2 instance with customizable settings.

## Overview

The module creates the following AWS resources:
- EC2 instance
- Security group with SSH access
- SSH key pair (if not existing)
- Associated networking components

## Requirements

- Terraform >= 1.0
- AWS provider
- AWS credentials configured
- SSH key pair (existing or will be created)

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|:--------:|
| region | AWS region where resources will be created | string | "us-east-1" | yes |
| ami_id | AMI ID for the EC2 instance | string | "ami-09eb231ad55c3963d" | yes |
| instance_type | Type of EC2 instance | string | "t2.micro" | no |
| instance_name | Name tag for the EC2 instance | string | "bigo" | no |
| ssh_key_name | Name of the SSH key pair | string | - | yes |
| environment | Environment tag (e.g., prod, dev) | string | "production" | no |
| allowed_ssh_ips | List of IP ranges allowed for SSH access | list(string) | ["0.0.0.0/0"] | no |

## Outputs

| Output | Description |
|--------|-------------|
| instance_public_ip | The public IP address of the EC2 instance |
| ssh_command | Ready-to-use SSH command for connecting to the instance |
| instance_id | The ID of the created EC2 instance |

## Usage

### Basic Example

```hcl
module "ec2_instance" {
  source = "./"

  region        = "us-east-1"
  instance_type = "t2.micro"
  ssh_key_name  = "my-key-pair"
  
  allowed_ssh_ips = ["10.0.0.0/8"]
}
```

### Complete Example

```hcl
module "ec2_instance" {
  source = "./"

  region        = "us-west-2"
  ami_id        = "ami-09eb231ad55c3963d"
  instance_type = "t2.small"
  instance_name = "web-server"
  ssh_key_name  = "production-key"
  environment   = "production"
  
  allowed_ssh_ips = [
    "192.168.1.0/24",
    "10.0.0.0/8"
  ]
}
```

## Deployment Instructions

1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-directory>
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. To destroy the resources:
```bash
terraform destroy
```

## Connecting to the Instance

After successful deployment, use the output SSH command to connect to your instance:
```bash
# The module will output the exact command to use
terraform output ssh_command
```

## Security Considerations

1. Always restrict `allowed_ssh_ips` to specific IP ranges
2. Regularly rotate SSH keys
3. Consider using Systems Manager Session Manager for secure access
4. Monitor instance access through CloudWatch

## Best Practices

1. Use specific AMI IDs rather than relying on defaults
2. Tag resources appropriately for cost allocation
3. Use appropriate instance types for your workload
4. Implement proper security group rules

## Troubleshooting

Common issues and solutions:

1. **SSH Connection Failed**
   - Verify security group rules
   - Check SSH key permissions
   - Confirm instance is running

2. **Resource Creation Failed**
   - Verify AWS credentials
   - Check VPC limits
   - Ensure sufficient IAM permissions

## Maintenance

- Regularly update the AMI ID to get the latest security patches
- Review and update security group rules as needed
- Monitor instance metrics and logs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This module is released under the MIT License.

---

For more detailed information about the AWS resources used in this module, refer to:
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)