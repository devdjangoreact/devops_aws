# Simple EC2 Instance in Frankfurt

This Terraform configuration creates a simple EC2 instance in AWS Frankfurt region (eu-central-1) with Docker, SSH key access, and web applications.

## Prerequisites

- AWS CLI configured with credentials
- Terraform installed
- SSH client (OpenSSH for Windows)

## SSH Key Setup for Windows PowerShell

### Automatic Key Generation

Terraform automatically generates an SSH key pair for secure access to your EC2 instance.

**1. After deploying, save the private key:**
```powershell
terraform output -raw ssh_private_key | Out-File -FilePath ec2-ssh-key.pem -Encoding ASCII
```

**2. Set proper permissions (Windows PowerShell):**
```powershell
# This is optional on Windows but recommended
icacls ec2-ssh-key.pem /inheritance:r /grant:r "$($env:USERNAME):F"
```

**3. Connect to your instance:**
```powershell
ssh -i ec2-ssh-key.pem ec2-user@<instance-public-ip>
```

### Alternative: Using PuTTY on Windows

If you prefer PuTTY over OpenSSH:

**1. Install PuTTY and PuTTYgen**

**2. Convert PEM to PPK format:**
- Open PuTTYgen
- Load the `ec2-ssh-key.pem` file
- Save private key as `ec2-ssh-key.ppk`

**3. Connect using PuTTY:**
- Host: `ec2-user@<instance-public-ip>`
- Connection → SSH → Auth → Private key file: `ec2-ssh-key.ppk`

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

## Applications Access

After deployment, your applications will be available at:

- **Main Web Server**: `http://<instance-public-ip>`
- **Symfony API**: `http://<instance-public-ip>:4444`
- **Angular4 App**: `http://<instance-public-ip>:5555`

## Configuration

- **Region**: eu-central-1 (Frankfurt)
- **Instance Type**: t3.micro (free tier)
- **AMI**: Amazon Linux 2 (latest)
- **SSH Key**: Auto-generated RSA 4096-bit key
- **Security**: Ports 22, 80, 443, 4444, 5555 open
- **Docker**: Installed with Compose
- **Applications**: Symfony API + Angular4 frontend

## Troubleshooting

If you can't connect via SSH:

1. **Check key permissions**: Ensure `ec2-ssh-key.pem` has restrictive permissions
2. **Verify instance state**: Instance should be "running"
3. **Check security group**: Port 22 should be open
4. **Try verbose SSH**: `ssh -v -i ec2-ssh-key.pem ec2-user@<instance-public-ip>`

For application issues, see `troubleshoot-apps.md`.

## Outputs

After deployment, Terraform provides:
- SSH private key (sensitive)
- SSH connection command
- Application URLs
- Instance details

## Security Notes

- SSH private key is generated uniquely per deployment
- Key is marked as sensitive in Terraform outputs
- Never commit private keys to version control
- SSH access is restricted to key-based authentication

