# Terraform AWS Infrastructure Module

This Terraform module provisions AWS infrastructure including an EC2 instance, a security group, and associated networking components. It employs user-defined variables to allow configuration customization and outputs vital instance information for further use.

## Resources Created

- **EC2 Instance**: A virtual machine provisioned in AWS with specified instance type and AMI.
- **Security Group**: Manages inbound SSH access from allowed IPs.
- **VPC and Subnet**: Configurable virtual private cloud and subnet for the instance network.

## Input Variables

| Name              | Description                                              | Type   | Default         |
|-------------------|----------------------------------------------------------|--------|--------------------|
| `region`          | AWS region for deployment.                               | string | `us-east-1`     |
| `ami_id`          | AMI ID for the EC2 instance, defining the OS and specs.  | string | `ami-09eb231ad55c3963d` |
| `instance_type`   | Type of EC2 instance (e.g., `t2.micro`, `m4.large`).     | string | `t2.micro`      |
| `instance_name`   | Tag name for the EC2 instance for easy identification.   | string | `example-instance` |
| `ssh_key_name`    | Name of the SSH key pair to enable access to the instance. | string | `my-key-pair`   |
| `environment`     | Tag denoting the environment (e.g., `development`, `production`). | string | `development`  |
| `allowed_ssh_ips` | CIDR blocks allowed for SSH access. Can be set to restrict or open access. | string | `0.0.0.0/0`    |

## Outputs

- **`instance_public_ip`**: The public IP address assigned to the EC2 instance, used for SSH access and network communication.
- **`ssh_command_example`**: A preformatted SSH command to facilitate quick access to the EC2 instance.

## Usage

To use this module, instantiate it in your Terraform configuration, specifying any necessary input variables:

```hcl
module "aws_infrastructure" {
  source           = "./aws_infrastructure"
  region           = "us-east-1"
  ami_id           = "ami-09eb231ad55c3963d"
  instance_type    = "t2.small"
  ssh_key_name     = "my-existing-key"
  allowed_ssh_ips  = "203.0.113.0/24"
}
```

## Applying the Module

Follow these steps to deploy the infrastructure:

1. **Initialize the Terraform Module:**

   ```bash
   terraform init
   ```

   This command sets up the working directory by downloading provider plugins and initializing the backend.

2. **Plan Infrastructure Changes:**

   ```bash
   terraform plan
   ```

   The planning step simulates the changes that will be made to the infrastructure without executing them, offering a preview of resources to be created, modified, or destroyed.

3. **Apply Changes:**

   ```bash
   terraform apply
   ```

   Deploys the infrastructure changes by provisioning the specified resources on AWS.

## Notes

- Ensure the SSH key pair referenced by `ssh_key_name` exists in the specified AWS region prior to applying the configuration.
- Consider security best practices when setting `allowed_ssh_ips` to restrict access to known IP ranges.
- Use the outputs to configure further network interactions or automate the connection process to the EC2 instance. 

This README.md provides a comprehensive guide to deploying and configuring the AWS infrastructure using this Terraform module. Modify the input variables as per your requirements to customize the infrastructure setup.