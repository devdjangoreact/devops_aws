# AWS Migration Infrastructure Project - Multi-Environment Deployment
#
# This project supports deploying all environments (dev, staging, production) from the root level,
# or deploying individual environments separately.
#
# Project Structure:
# ├── modules/          - Reusable Terraform modules
# │   ├── ec2-instance/ - EC2 instance with SSH key generation
# │   └── networking/   - Security groups and networking
# ├── environments/     - Environment-specific configurations
# │   ├── dev/          - Development environment
# │   ├── staging/      - Staging environment
# │   └── production/   - Production environment (2 instances for blue-green)
# ├── scripts/          - Helper scripts and application files
# └── docs/            - Documentation
#
# DEPLOYMENT OPTIONS:
#
# 1. Deploy ALL environments from root:
#    terraform init
#    terraform plan -var-file=terraform.tfvars
#    terraform apply -var-file=terraform.tfvars
#
# 2. Deploy individual environments:
#    cd environments/dev && terraform init && terraform plan && terraform apply
#    cd environments/staging && terraform init && terraform plan && terraform apply
#    cd environments/production && terraform init && terraform plan && terraform apply
#
# 3. Deploy specific environments using variables:
#    terraform plan -var="deploy_dev=true" -var="deploy_staging=true" -var="deploy_production=false"
#    terraform apply -var="deploy_dev=true" -var="deploy_staging=true" -var="deploy_production=false"

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Development Environment
module "dev" {
  count  = var.deploy_dev ? 1 : 0
  source = "./environments/dev"

  aws_region    = var.aws_region
  instance_type = var.instance_type
}

# Staging Environment
module "staging" {
  count  = var.deploy_staging ? 1 : 0
  source = "./environments/staging"

  aws_region    = var.aws_region
  instance_type = var.instance_type
}

# Production Environment (2 instances for blue-green)
module "production" {
  count  = var.deploy_production ? 1 : 0
  source = "./environments/production"

  aws_region    = var.aws_region
  instance_type = var.instance_type
}
