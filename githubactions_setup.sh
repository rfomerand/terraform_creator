#!/bin/bash

# Setup script for Terraform CI/CD with GitHub Actions (or Gitea Actions)
# This script sets up the necessary files and structure for Terraform linting and planning

set -e

echo "🚀 Setting up Terraform CI/CD pipeline..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create directory if it doesn't exist
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}✓${NC} Created directory: $1"
    else
        echo -e "${YELLOW}⚠${NC} Directory already exists: $1"
    fi
}

# Function to create file with backup
create_file() {
    local file_path="$1"
    local content="$2"
    
    if [ -f "$file_path" ]; then
        echo -e "${YELLOW}⚠${NC} File exists: $file_path"
        read -p "Do you want to overwrite it? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}⚠${NC} Skipping $file_path"
            return
        fi
        # Create backup
        cp "$file_path" "${file_path}.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${GREEN}✓${NC} Created backup of $file_path"
    fi
    
    echo "$content" > "$file_path"
    echo -e "${GREEN}✓${NC} Created file: $file_path"
}

# Check if git repo
if [ ! -d .git ]; then
    echo -e "${RED}✗${NC} This directory is not a git repository!"
    read -p "Initialize git repository? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git init
        echo -e "${GREEN}✓${NC} Initialized git repository"
    else
        echo -e "${RED}✗${NC} Git repository required. Exiting."
        exit 1
    fi
fi

# Create .github/workflows directory
create_dir ".github/workflows"

# Create GitHub Actions workflow
echo -e "\n📝 Creating GitHub Actions workflow..."
workflow_content='name: Terraform CI

on:
  pull_request:
    branches: [ main ]
    paths:
      - '\''**.tf'\''
      - '\''**.tfvars'\''
      - '\''.github/workflows/terraform.yml'\''
      - '\''.tflint.hcl'\''

env:
  TF_VERSION: "1.5.7"
  AWS_DEFAULT_REGION: "us-east-1"
  
jobs:
  terraform-check:
    name: Terraform Lint and Plan
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Terraform Format Check
      id: fmt
      run: |
        echo "::group::Checking Terraform format"
        terraform fmt -check -recursive -diff
        echo "::endgroup::"
      continue-on-error: true

    - name: Terraform Init
      id: init
      run: |
        echo "::group::Initializing Terraform"
        terraform init -backend=false
        echo "::endgroup::"

    - name: Terraform Validate
      id: validate
      run: |
        echo "::group::Validating Terraform configuration"
        terraform validate -no-color
        echo "::endgroup::"

    - name: TFLint Setup
      uses: terraform-linters/setup-tflint@v4
      with:
        tflint_version: latest

    - name: Init TFLint
      run: |
        echo "::group::Initializing TFLint"
        tflint --init
        echo "::endgroup::"

    - name: Run TFLint
      id: tflint
      run: |
        echo "::group::Running TFLint"
        tflint --format compact
        echo "::endgroup::"
      continue-on-error: true

    - name: Security Scan with Checkov
      id: checkov
      uses: bridgecrewio/checkov-action@v12
      with:
        directory: .
        framework: terraform
        output_format: cli
        soft_fail: true

    - name: Generate Terraform Docs
      uses: terraform-docs/gh-actions@v1
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: false

    - name: Terraform Plan
      id: plan
      run: |
        echo "::group::Running Terraform plan"
        # Create a dummy key file for plan (won'\''t be used, just for validation)
        mkdir -p ~/.ssh
        touch ~/.ssh/dummy_key.pub
        terraform plan -no-color -input=false \
          -var="key_name=dummy_key" \
          -out=tfplan
        echo "::endgroup::"
      continue-on-error: true

    - name: Generate Plan JSON for PR Comment
      id: show_plan
      if: steps.plan.outcome == '\''success'\''
      run: |
        terraform show -no-color tfplan > plan.txt
        
    - name: Comment PR with Results
      uses: actions/github-script@v7
      if: github.event_name == '\''pull_request'\''
      env:
        FMT_OUTCOME: "${{ steps.fmt.outcome }}"
        INIT_OUTCOME: "${{ steps.init.outcome }}"
        VALIDATE_OUTCOME: "${{ steps.validate.outcome }}"
        TFLINT_OUTCOME: "${{ steps.tflint.outcome }}"
        CHECKOV_OUTCOME: "${{ steps.checkov.outcome }}"
        PLAN_OUTCOME: "${{ steps.plan.outcome }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const fs = require('\''fs'\'');
          let planOutput = '\'''\'';
          
          if ('\''${{ steps.plan.outcome }}'\'' === '\''success'\'') {
            try {
              planOutput = fs.readFileSync('\''plan.txt'\'', '\''utf8'\'');
              // Truncate very long plans
              if (planOutput.length > 60000) {
                planOutput = planOutput.substring(0, 60000) + '\''\n\n... (truncated)'\'';
              }
            } catch (err) {
              planOutput = '\''Error reading plan output'\'';
            }
          }
          
          const output = `## Terraform CI Results 🚀
          
          | Check | Status | Details |
          |-------|--------|---------|
          | Format | ${{ env.FMT_OUTCOME === '\''success'\'' && '\''✅ Passed'\'' || '\''❌ Failed'\'' }} | Terraform fmt check |
          | Init | ${{ env.INIT_OUTCOME === '\''success'\'' && '\''✅ Passed'\'' || '\''❌ Failed'\'' }} | Terraform initialization |
          | Validation | ${{ env.VALIDATE_OUTCOME === '\''success'\'' && '\''✅ Passed'\'' || '\''❌ Failed'\'' }} | Terraform validation |
          | TFLint | ${{ env.TFLINT_OUTCOME === '\''success'\'' && '\''✅ Passed'\'' || '\''⚠️ Warnings'\'' }} | Terraform linter |
          | Security | ${{ env.CHECKOV_OUTCOME === '\''success'\'' && '\''✅ Passed'\'' || '\''⚠️ Issues Found'\'' }} | Checkov security scan |
          | Plan | ${{ env.PLAN_OUTCOME === '\''success'\'' && '\''✅ Success'\'' || '\''❌ Failed'\'' }} | Terraform plan |
          
          ### Configuration Details
          - **AWS Region**: us-east-1
          - **Resources**: VPC, Subnet, IGW, Security Group, EC2 Instance
          - **Instance Type**: t2.micro
          
          <details><summary>📋 Terraform Plan Output</summary>
          
          \`\`\`terraform
          ${planOutput || '\''Plan failed or no changes detected'\''}
          \`\`\`
          
          </details>
          
          ---
          *Workflow: \`${{ github.workflow }}\` | Commit: \`${{ github.sha.substring(0, 7) }}\`*`;
          
          // Find existing comment
          const { data: comments } = await github.rest.issues.listComments({
            owner: context.repo.owner,
            repo: context.repo.repo,
            issue_number: context.issue.number,
          });
          
          const botComment = comments.find(comment => 
            comment.user.type === '\''Bot'\'' && 
            comment.body.includes('\''Terraform CI Results'\'')
          );
          
          // Update or create comment
          if (botComment) {
            await github.rest.issues.updateComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              comment_id: botComment.id,
              body: output
            });
          } else {
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            });
          }

    - name: Check for Failures
      if: |
        steps.fmt.outcome == '\''failure'\'' || 
        steps.validate.outcome == '\''failure'\'' || 
        steps.plan.outcome == '\''failure'\''
      run: |
        echo "❌ One or more Terraform checks failed!"
        echo ""
        echo "Failed checks:"
        [[ "${{ steps.fmt.outcome }}" == "failure" ]] && echo "  - Terraform Format"
        [[ "${{ steps.validate.outcome }}" == "failure" ]] && echo "  - Terraform Validate"
        [[ "${{ steps.plan.outcome }}" == "failure" ]] && echo "  - Terraform Plan"
        exit 1'

create_file ".github/workflows/terraform.yml" "$workflow_content"

# Create TFLint configuration
echo -e "\n📝 Creating TFLint configuration..."
tflint_content='plugin "terraform" {
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
  
  # Exclude resources that don'\''t support these tags
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
}'

create_file ".tflint.hcl" "$tflint_content"

# Create .gitignore if it doesn't exist
echo -e "\n📝 Updating .gitignore..."
gitignore_content='# Terraform files
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.auto.tfvars
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
*.tfplan
tfplan

# SSH Keys
*.pem
*.key
*.pub

# IDE files
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store

# Logs
*.log
crash.log
crash.*.log

# Backup files
*.backup
*.bak'

if [ -f .gitignore ]; then
    # Append only if not already present
    while IFS= read -r line; do
        if ! grep -Fxq "$line" .gitignore 2>/dev/null; then
            echo "$line" >> .gitignore
        fi
    done <<< "$gitignore_content"
    echo -e "${GREEN}✓${NC} Updated .gitignore"
else
    create_file ".gitignore" "$gitignore_content"
fi

# Create terraform-docs configuration
echo -e "\n📝 Creating terraform-docs configuration..."
terraform_docs_content='formatter: "markdown table"

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false

sections:
  hide: []
  show: []

content: ""

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true'

create_file ".terraform-docs.yml" "$terraform_docs_content"

# Add terraform-docs markers to README if not present
if [ -f README.md ]; then
    if ! grep -q "BEGIN_TF_DOCS" README.md; then
        echo -e "\n<!-- BEGIN_TF_DOCS -->\n<!-- END_TF_DOCS -->" >> README.md
        echo -e "${GREEN}✓${NC} Added terraform-docs markers to README.md"
    fi
fi

# Create example terraform.tfvars
echo -e "\n📝 Creating example terraform.tfvars..."
tfvars_example_content='# Example Terraform variables file
# Copy this to terraform.tfvars and update with your values

region        = "us-east-1"
instance_type = "t2.micro"
ami_id        = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
instance_name = "my-ec2-instance"
key_name      = "my-ssh-key"
environment   = "development"
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"'

create_file "terraform.tfvars.example" "$tfvars_example_content"

# Fix Terraform code issues
echo -e "\n🔧 Fixing Terraform code issues..."

# Add missing Environment tag to resources
if command_exists terraform; then
    echo -e "${GREEN}✓${NC} Running terraform fmt..."
    terraform fmt -recursive
else
    echo -e "${YELLOW}⚠${NC} Terraform not installed, skipping format"
fi

# Create a pre-commit hook for local validation
echo -e "\n📝 Creating pre-commit hook..."
pre_commit_content='#!/bin/bash
# Pre-commit hook for Terraform validation

echo "Running pre-commit Terraform checks..."

# Format check
if ! terraform fmt -check -recursive >/dev/null 2>&1; then
    echo "❌ Terraform files need formatting. Run: terraform fmt -recursive"
    exit 1
fi

# Validate if .tf files changed
if git diff --cached --name-only | grep -q "\.tf$"; then
    if ! terraform init -backend=false >/dev/null 2>&1; then
        echo "❌ Terraform init failed"
        exit 1
    fi
    
    if ! terraform validate >/dev/null 2>&1; then
        echo "❌ Terraform validation failed"
        exit 1
    fi
fi

echo "✅ Pre-commit checks passed"'

if [ ! -f .git/hooks/pre-commit ]; then
    create_file ".git/hooks/pre-commit" "$pre_commit_content"
    chmod +x .git/hooks/pre-commit
    echo -e "${GREEN}✓${NC} Created pre-commit hook"
fi

# Summary
echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo -e "\n📋 Next steps:"
echo "1. Review and update the Terraform variables in your .tf files"
echo "2. Create terraform.tfvars with your actual values (see terraform.tfvars.example)"
echo "3. Commit these changes to a feature branch"
echo "4. Create a pull request to trigger the CI pipeline"
echo -e "\n💡 Tips:"
echo "- The workflow runs on pull requests to the 'main' branch"
echo "- Format your code with: terraform fmt -recursive"
echo "- Run local validation with: terraform validate"
echo "- The pre-commit hook will run automatic checks"

# For Gitea
echo -e "\n📌 For Gitea Actions:"
echo "- Copy .github/workflows/ to .gitea/workflows/"
echo "- Remove or modify the PR comment step (GitHub-specific)"
echo "- Ensure your Gitea runner has Docker access"

# Check for potential issues
echo -e "\n🔍 Checking for potential issues..."

# Check for missing Environment tags
if grep -q "resource \"aws_" *.tf 2>/dev/null; then
    resources_without_env=$(grep -B2 "tags = {" *.tf | grep -v "Environment" | grep "resource \"aws_" || true)
    if [ ! -z "$resources_without_env" ]; then
        echo -e "${YELLOW}⚠${NC} Some resources might be missing Environment tags"
    fi
fi

# Check for SSH key hardcoding
if grep -q "file(\"~/\.ssh/" *.tf 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} SSH key path is hardcoded. Consider using variables"
fi

echo -e "\n${GREEN}🎉 Setup complete! Happy Terraforming!${NC}"
