# AWS Migration Infrastructure - Deployment Guide

## 🎯 What Was Accomplished

Successfully restructured the Terraform project to support **multi-environment deployment** with the following capabilities:

### ✅ **3 Environments Created:**
- **Development**: 1 EC2 instance for development/testing
- **Staging**: 1 EC2 instance for staging/validation
- **Production**: 2 EC2 instances for blue-green deployment

### ✅ **Flexible Deployment Options:**
1. **Deploy all environments** from root level
2. **Deploy individual environments** separately
3. **Deploy specific combinations** using variables

### ✅ **Production Blue-Green Setup:**
- 2 EC2 instances (primary + secondary)
- Ready for traffic switching between instances
- Separate outputs for each instance

## 🚀 Deployment Commands

### Quick Deploy All Environments:
```bash
terraform init
terraform apply -var="deploy_dev=true" -var="deploy_staging=true" -var="deploy_production=true"
```

### Individual Environment Deployment:
```bash
# Dev only
cd environments/dev && terraform init && terraform apply

# Staging only
cd environments/staging && terraform init && terraform apply

# Production only (2 instances)
cd environments/production && terraform init && terraform apply
```

### Selective Deployment:
```bash
# Dev + Staging only
terraform apply -var="deploy_dev=true" -var="deploy_staging=true"

# Production only
terraform apply -var="deploy_production=true"
```

## 📊 Environment Specifications

| Environment | Instances | Purpose | Applications |
|-------------|-----------|---------|--------------|
| **Dev** | 1 | Development & testing | Symfony API + Angular4 |
| **Staging** | 1 | Pre-production validation | Symfony API + Angular4 |
| **Production** | 2 | Live environment | Symfony API + Angular4 (blue-green) |

## 🔧 Applications Per Environment

Each environment runs identical applications:
- **Port 80**: Nginx web server
- **Port 4444**: Symfony API (PHP)
- **Port 5555**: Angular4 frontend

### Environment Branding:
- **Dev**: "Development Environment"
- **Staging**: "Staging Environment"
- **Production**: "Production Environment"

## 🗝️ SSH Access

After deployment, each environment provides unique SSH keys:

```bash
# Save SSH key (replace with actual environment)
terraform output -raw dev_ssh_private_key > dev-key.pem
chmod 600 dev-key.pem

# Connect
ssh -i dev-key.pem ec2-user@<instance-ip>
```

## 📈 Scaling Strategy

### Current Setup:
- **Dev/Staging**: Single instances for development
- **Production**: Dual instances for high availability

### Future Scaling:
- Add load balancers for production
- Implement auto-scaling groups
- Add RDS databases per environment

## 🔄 Blue-Green Deployment (Production)

Production environment supports blue-green deployment:

1. **Primary Instance**: Active/live traffic
2. **Secondary Instance**: Standby for deployments
3. **Traffic Switching**: Manual switching between instances
4. **Rollback**: Quick reversion to previous version

## 📋 Migration Workflow

1. **Develop** → Deploy to Dev environment
2. **Test** → Promote to Staging environment
3. **Validate** → Deploy to Production secondary instance
4. **Switch Traffic** → Route traffic to new production instance
5. **Monitor** → Verify production stability
6. **Cleanup** → Scale down old production instance

## 🛠️ Troubleshooting

### Check Deployment Status:
```bash
terraform output deployment_summary
```

### View Environment-Specific Outputs:
```bash
terraform output dev_instance_public_ip
terraform output staging_application_urls
terraform output production_primary_instance_public_ip
```

### SSH Access Issues:
```bash
# Ensure key has correct permissions
icacls ec2-ssh-key.pem /inheritance:r /grant:r "$($env:USERNAME):F"
```

### Application Issues:
```bash
# SSH to instance and check
./test-apps.sh
docker-compose ps
docker-compose logs
```

## 🎉 Success Metrics

✅ **Multi-environment support** - Dev, Staging, Production
✅ **Blue-green production** - 2 instances for zero-downtime deployments
✅ **Flexible deployment** - All, individual, or selective
✅ **Automated SSH keys** - Secure access per environment
✅ **Application consistency** - Same apps across all environments
✅ **Infrastructure as Code** - Version-controlled, reproducible

## 🚀 Next Steps

1. **Test deployments** in each environment
2. **Implement CI/CD** pipelines for automated deployments
3. **Add monitoring** (CloudWatch, alerts)
4. **Configure load balancers** for production
5. **Set up databases** (RDS) per environment
6. **Implement backup strategies**

This infrastructure provides a solid foundation for your Angular4 and Symfony migration with enterprise-grade deployment capabilities!
