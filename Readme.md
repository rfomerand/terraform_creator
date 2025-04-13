```markdown
# AWS EC2 Terraform Module

This module provisions an AWS EC2 instance with the specified configuration. It automates the setup focusing on computation and storage specifications, using Terraform infrastructure-as-code principles.

## Features

* Launch an EC2 instance in the specified subnet and VPC.
* Configure instance with 8 CPUs and 16 GB of RAM.
* Provide 100 GB of EBS storage.
* Utilize a specific Amazon Machine Image (AMI).
* Automatically create and assign a new SSH Key Pair.
* Assign customer-defined tags for easy identification.

## Requirements

* Terraform v0.12 or later
* AWS Account credentials with EC2 and IAM permissions

## Usage

Clone the repository and navigate into it:

```bash
git clone https://github.com/yourusername/yourrepo.git
cd yourrepo
```

Initialize Terraform to download necessary plugins:

```bash
terraform init
```

Apply the configuration to launch the instance:

```bash
terraform apply
```

Type `yes` when prompted to confirm the execution plan.

## Variables

The following are key variables in the module:

| Variable             | Description                                                  | Default Value               |
|----------------------|--------------------------------------------------------------|-----------------------------|
| `region`             | The AWS region to deploy the instance                        | `us-east-1`                 |
| `subnet_id`          | Subnet ID where the instance will reside                     | `subnet-09c236516b8b7ee09`  |
| `vpc_id`             | VPC ID associated with the subnet                            | `vpc-058616e90fd00cb07`     |
| `instance_type`      | EC2 instance type to launch                                  | `t2.xlarge`                 |
| `ami_id`             | AMI ID to use for the instance                               | `ami-09eb231ad55c3963d`     |
| `key_name`           | Name of the SSH Key Pair                                     | `auto-generated`            |
| `storage_size_gb`    | Size of EBS block storage (in GB)                            | `100`                       |

## Outputs

Following are the outputs made available:

| Output               | Description                                                  |
|----------------------|--------------------------------------------------------------|
| `instance_id`        | ID of the created EC2 instance                               |
| `public_ip`          | Public IP address assigned to the instance                   |
| `private_ip`         | Private IP address assigned to the instance                  |
| `key_pair_id`        | ID of the SSH Key Pair created for access                    |

## Configuration

Ensure that your AWS credentials are correctly configured in `aws configure`.

## Contributing

Feel free to submit issues, fork the repository and send pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

* This project utilizes Terraform to provision AWS Infrastructure.
* Configuration setup inspired by multiple AWS and Terraform community modules.
```

### Commit to Git

```bash
git add README.md
git commit -m "Add README.md documentation"
git push origin main
```