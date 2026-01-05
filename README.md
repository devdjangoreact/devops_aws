# AWS Migration Infrastructure Project

A well-structured Terraform project for deploying AWS infrastructure for Angular4 and Symfony application migrations.

## Project Structure

```
aws-migration-infrastructure/
├── modules/                    # Reusable Terraform modules
│   ├── ec2-instance/          # EC2 instance with SSH key generation
│   │   ├── main.tf            # EC2 instance and key resources
│   │   ├── variables.tf       # Module variables
│   │   └── outputs.tf         # Module outputs
│   └── networking/            # Security groups and networking
│       ├── main.tf            # Security group configuration
│       ├── variables.tf       # Module variables
│       └── outputs.tf         # Module outputs
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment (1 instance)
│   │   ├── main.tf            # Dev configuration
│   │   ├── variables.tf       # Dev variables
│   │   └── outputs.tf         # Dev outputs
│   ├── staging/               # Staging environment (1 instance)
│   │   ├── main.tf            # Staging configuration
│   │   ├── variables.tf       # Staging variables
│   │   └── outputs.tf         # Staging outputs
│   └── production/            # Production environment (2 instances)
│       ├── main.tf            # Production configuration
│       ├── variables.tf       # Production variables
│       └── outputs.tf         # Production outputs
├── scripts/                   # Helper scripts and application files
│   ├── test-apps.sh          # Application testing script
│   ├── symfony-app/          # Symfony API application files
│   ├── angular-app/          # Angular4 application files
│   └── docker-compose.yml    # Docker Compose configuration
├── docs/                     # Documentation
│   └── migration-plan.md     # Detailed migration plan
├── main.tf                   # Root level documentation
├── variables.tf              # Root level variables
├── outputs.tf                # Root level outputs
├── terraform.tfvars          # Variable values
└── .gitignore               # Git ignore rules
```

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0.0
- SSH client (OpenSSH for Windows)

## Quick Start

### Option 1: Deploy Multiple Environments from Root
```bash
# Initialize (only needed once)
terraform init

# Deploy all environments
terraform apply -var="deploy_dev=true" -var="deploy_staging=true" -var="deploy_production=true"

# Deploy specific combinations
terraform apply -var="deploy_dev=true" -var="deploy_staging=true"
terraform apply -var="deploy_production=true"  # Only production (2 instances)

# Check what will be deployed without applying
terraform plan -var="deploy_dev=true" -var="deploy_staging=true"
```

### Option 2: Deploy Individual Environments
```bash
# Development environment (1 instance)
cd environments/dev && terraform init && terraform plan && terraform apply

# Staging environment (1 instance)
cd environments/staging && terraform init && terraform plan && terraform apply

# Production environment (2 instances for blue-green deployment)
cd environments/production && terraform init && terraform plan && terraform apply
```

### Option 3: Use terraform.tfvars for Persistent Settings
Edit `terraform.tfvars`:
```hcl
deploy_dev        = true
deploy_staging    = true
deploy_production = false
```

Then run:
```bash
terraform apply -var-file=terraform.tfvars
```

## SSH Key Setup (Windows PowerShell)

### Automatic Key Generation

Each environment automatically generates unique SSH key pairs.

**1. Save the private key after deployment:**
```powershell
terraform output -raw ssh_private_key | Out-File -FilePath ec2-ssh-key.pem -Encoding ASCII
```

**2. Connect to your instance:**
```powershell
ssh -i ec2-ssh-key.pem ec2-user@<instance-public-ip>
```

### Alternative: PuTTY
- Use PuTTYgen to convert `.pem` to `.ppk` format
- Use PuTTY to connect with the private key

## Applications

Each environment deploys identical applications:

- **Main Web Server**: `http://<public-ip>` (Nginx)
- **Symfony API**: `http://<public-ip>:4444` (PHP endpoints)
- **Angular4 App**: `http://<public-ip>:5555` (Frontend interface)

### Environment Branding
- **Dev**: Shows "Development Environment" branding
- **Staging**: Shows "Staging Environment" branding
- **Production**: Shows "Production Environment" branding + 2 instances for blue-green deployment

### API Endpoints

**Symfony API (Port 4444):**
- `GET /api/health` - Health check with environment info
- `GET /api/users` - Sample user data

**Angular4 App (Port 5555):**
- Interactive frontend with API connectivity testing
- Real-time status display
- Direct links to API endpoints

## Configuration

### Instance Configuration
- **Region**: eu-central-1 (Frankfurt)
- **Instance Type**: t3.micro (Free Tier eligible)
- **AMI**: Amazon Linux 2 (latest)
- **SSH Key**: Auto-generated RSA 4096-bit

### Security
- **Open Ports**: 22 (SSH), 80 (HTTP), 443 (HTTPS), 4444 (Symfony), 5555 (Angular4)
- **Security Groups**: Environment-specific with proper ingress rules
- **SSH Access**: Key-based authentication only

### Applications
- **Docker**: Automatically installed and configured
- **Docker Compose**: Latest version for container orchestration
- **Environment-specific**: Staging/Production configurations

## Environment Differences

### Staging
- Named resources include "staging" prefix
- Applications show "Staging Environment" branding
- API responses include `environment: "staging"`

### Production
- Named resources include "production" prefix
- Applications show "Production Environment" branding
- API responses include `environment: "production"`

## Troubleshooting

### SSH Connection Issues
```bash
# Check key permissions
icacls ec2-ssh-key.pem /inheritance:r /grant:r "$($env:USERNAME):F"

# Test connection with verbose output
ssh -v -i ec2-ssh-key.pem ec2-user@<instance-public-ip>
```

### Application Issues
```bash
# SSH to instance and run diagnostics
./test-apps.sh

# Check container status
docker-compose ps

# View logs
docker-compose logs
```

### Terraform Issues
```bash
# Reinitialize providers
terraform init -upgrade

# Check current state
terraform state list

# Clean up state (use with caution)
terraform state rm <resource>
```

## Migration Context

This infrastructure supports the Angular4 and Symfony migration plan outlined in `docs/migration-plan.md`. It provides:

- **Parallel Environments**: Separate staging/production for testing migrations
- **Containerized Applications**: Docker-based deployment ready for version upgrades
- **Blue-Green Ready**: Infrastructure prepared for deployment strategies
- **Monitoring Ready**: CloudWatch integration points available

## Outputs

Each environment provides:
- Instance details (ID, IP, state)
- SSH private key (sensitive)
- Connection commands
- Application URLs
- Security group information

## Security Considerations

- SSH keys are generated uniquely per deployment
- Private keys are marked sensitive and not logged
- Security groups follow least-privilege principles
- All resources are tagged with environment information

## Cleanup

To destroy resources:
```bash
cd environments/<environment>
terraform destroy
```

## Contributing

1. Use modules for reusable components
2. Environment-specific configurations go in `environments/`
3. Scripts and application files in `scripts/`
4. Documentation in `docs/`
5. Test in staging before production deployment

