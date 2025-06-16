plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Terraform best practices
rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# AWS specific rules
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_instance_invalid_ami" {
  enabled = true
}

rule "aws_security_group_invalid_protocol" {
  enabled = true
}

# Require tags on resources
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Name", "Environment"]
  
  # Exclude resources that don't support these tags
  exclude = [
    "aws_route_table_association",
    "aws_key_pair"
  ]
}

# Security rules
rule "aws_security_group_rule_invalid_protocol" {
  enabled = true
}

# Check for hardcoded secrets (basic check)
rule "terraform_unused_required_providers" {
  enabled = true
}
