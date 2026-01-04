# Simple EC2 Instance in Frankfurt

This Terraform configuration creates a simple EC2 instance in AWS Frankfurt region (eu-central-1).

## Prerequisites

- AWS CLI configured with credentials
- Terraform installed

## Usage

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Plan the deployment:

   ```bash
   terraform plan
   ```

3. Apply the configuration:

   ```bash
   terraform apply
   ```

4. To destroy the instance:
   ```bash
   terraform destroy
   ```

## Configuration

- **Region**: eu-central-1 (Frankfurt)
- **Instance Type**: t3.micro (free tier)
- **AMI**: Amazon Linux 2 (latest version, retrieved dynamically)
- **Name**: simple-ec2-instance

## Outputs

After deployment, Terraform will output:

- Instance ID
- Public IP address
- Instance state
