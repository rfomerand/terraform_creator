# AWS EC2 Instance Terraform Module

This module creates an EC2 instance in AWS along with the necessary networking components and security configurations. The module provides a complete solution for deploying a secure, accessible EC2 instance with customizable settings.

## Resources Created

The module provisions the following AWS resources:
* EC2 Instance
* VPC
* Internet Gateway
* Public Subnet
* Route Table
* Security Group
* SSH Key Pair (if not existing)

## Prerequisites

* AWS CLI installed and configured
* Terraform >= 0.12
* AWS credentials configured
* SSH key pair (optional - will be created if not specified)

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|:--------:|
| region | AWS region for deployment | string | "us-east-1" | no |
| ami_id | AMI ID for EC2 instance | string | "ami-09eb231ad55c3963d" | no |
| instance_type | EC2 instance size | string | "t2.micro" | no |
| instance_name | Name tag for EC2 instance | string | "bigo" | no |
| ssh_key_name | SSH key pair name | string | - | yes |
| environment | Environment tag value | string | "production" | no |
| allowed_ssh_ips | CIDR blocks allowed for SSH access | list(string) | ["0.0.0.0/0"] | no |

## Outputs

| Output | Description |
|--------|-------------|
| instance_public_ip | Public IP address of the EC2 instance |
| instance_id | ID of the created EC2 instance |
| ssh_command | Command to SSH into the instance |

## Usage

### Basic Example

```hcl
module "ec2_instance" {
  source = "./"

  ssh_key_name  = "my-key-pair"
  instance_name = "web-server"
}
```

### Advanced Example

```hcl
module "ec2_instance" {
  source = "./"

  region        = "us-west-2"
  instance_type = "t2.small"
  ssh_key_name  = "prod-key"
  instance_name = "production-server"
  environment   = "production"
  allowed_ssh_ips = [
    "10.0.0.0/8",
    "192.168.1.0/24"
  ]
}
```

## Deployment Instructions

1. Create a new directory for your Terraform configuration:
```bash
mkdir terraform-ec2
cd terraform-ec2
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the deployment plan:
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

## Security Considerations

1. SSH Access:
   * Default configuration allows SSH access from anywhere (0.0.0.0/0)
   * Modify `allowed_ssh_ips` to restrict access to specific IP ranges
   * Use secure SSH key management practices

2. Security Groups:
   * Only SSH port (22) is opened by default
   * Additional ports can be configured as needed
   * Follow principle of least privilege

## Best Practices

1. Always specify restricted IP ranges for SSH access
2. Use appropriate instance types for your workload
3. Tag resources appropriately using the environment variable
4. Regularly update the AMI ID to get the latest security patches
5. Back up important data and configurations

## Troubleshooting

Common issues and solutions:

1. SSH Connection Issues:
   * Verify security group rules
   * Check if the key pair exists
   * Ensure your IP is in the allowed_ssh_ips list

2. Resource Creation Failures:
   * Verify AWS credentials
   * Check resource limits
   * Ensure instance type is available in the selected region

## Maintenance

### Updating the Module

1. Modify variables in your configuration files
2. Run terraform plan to preview changes
3. Apply changes using terraform apply

### Monitoring and Logging

* Configure CloudWatch monitoring for the instance
* Enable detailed monitoring if needed
* Set up appropriate logging mechanisms

## Example Outputs

After successful deployment, you'll see:
```
Outputs:

instance_public_ip = "54.X.X.X"
instance_id = "i-1234567890abcdef0"
ssh_command = "ssh -i my-key-pair.pem ubuntu@54.X.X.X"
```

## Notes

* Default AMI is Ubuntu 20.04 LTS
* Instance receives a public IP automatically
* All resources are tagged with environment name
* VPC is created with a /16 CIDR block
* Subnet uses a /24 CIDR block

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This module is released under the MIT License.

## Support

For issues and feature requests:
* Open an issue in the repository
* Contact the maintainers