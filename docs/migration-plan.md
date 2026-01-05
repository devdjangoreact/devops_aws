# AWS Infrastructure Migration Plan

## Executive Summary

Based on the requirements document, this plan outlines the creation of parallel AWS environments for Angular and Symfony version migrations while preserving the existing infrastructure.

## Current Infrastructure Analysis

### Existing Setup
- **Environments**: dev01, staging01, production01
- **Applications**: 2 Angular4 frontend apps + 1 Symfony API backend
- **Deployment**: Jenkins-based with Blue-Green deployment
- **Containerization**: Docker for all applications
- **AWS Accounts**: Separate accounts for Production and Staging/Dev
- **Production**: 2 EC2 instances (active + standby scaled down)
- **Database**: RDS with Write and ReadOnly instances
- **CDN**: Cloudflare

## Migration Strategy: Parallel Environments

### Phase 1: Infrastructure Planning & Design

#### 1.1 Environment Architecture
```
Current Environments:
├── dev01 (Staging/Dev Account)
├── staging01 (Staging/Dev Account)
└── production01 (Production Account)
    ├── prod-instance (active)
    └── standby-instance (scaled down)

New Parallel Environments:
├── angular-migration (Staging/Dev Account)
│   ├── staging-front (1 instance)
│   └── production-front (2 instances - blue-green)
└── symfony-migration (Staging/Dev Account)
    ├── staging-back (1 instance)
    └── production-back (2 instances - blue-green)
```

#### 1.2 Required AWS Resources per Environment

**Compute (EC2):**
- Instance Type: t3.micro (Free Tier eligible)
- AMI: Amazon Linux 2 (latest via data source)
- Security Groups: Web access (80/443), SSH (22)
- Auto Scaling Groups for production environments

**Database (RDS):**
- Engine: MySQL (based on existing setup)
- Multi-AZ: Enabled for production
- Read Replicas: 1 for production environments
- Backup: Daily with 7-day retention

**Storage (EBS):**
- Root Volume: 20GB gp3
- Additional volumes as needed

**Networking:**
- VPC with public/private subnets
- Internet Gateway
- NAT Gateway for private subnets
- Route Tables
- Security Groups

**Load Balancing:**
- Application Load Balancer (ALB) for production
- Target Groups for blue-green deployment

**DNS & CDN:**
- Route 53 hosted zones
- Cloudflare integration (existing)

### Phase 2: Core Infrastructure Setup

#### 2.1 Terraform Module Structure
```
terraform/
├── modules/
│   ├── vpc/           # Networking components
│   ├── ec2/           # EC2 instances and launch templates
│   ├── rds/           # Database instances
│   ├── alb/           # Load balancers
│   └── security/      # Security groups and IAM
├── environments/
│   ├── angular-staging/
│   ├── angular-production/
│   ├── symfony-staging/
│   └── symfony-production/
└── shared/            # Shared resources
```

#### 2.2 Implementation Order
1. **Networking (VPC)**: Base networking infrastructure
2. **Security**: IAM roles, security groups, key pairs
3. **Database**: RDS instances and replicas
4. **Compute**: EC2 instances with auto-scaling
5. **Load Balancing**: ALBs and target groups
6. **DNS**: Route 53 configuration

### Phase 3: Migration-Specific Components

#### 3.1 Database Migration Strategy
- **Source**: Copy from existing environments
- **Method**: mysqldump or AWS DMS
- **Testing**: Validate data integrity post-migration
- **Rollback**: Keep original databases intact

#### 3.2 Application Deployment
- **Container Registry**: Amazon ECR for Docker images
- **CI/CD**: Update Jenkins pipelines or implement new ones
- **Blue-Green**: Implement proper blue-green with ALB

#### 3.3 Version Management
- **Frontend**: Angular version upgrades
- **Backend**: Symfony + PHP version upgrades
- **Dependencies**: Update Composer, Node.js, etc.

### Phase 4: Security & Compliance

#### 4.1 Security Groups
```
Web Servers:
- Inbound: 80/443 from Cloudflare IPs
- Inbound: 22 from bastion hosts only
- Outbound: All traffic

Database:
- Inbound: 3306 from application servers only
- Outbound: None
```

#### 4.2 IAM Roles
- EC2 instances: Read access to ECR, CloudWatch logs
- Deployment users: Limited permissions for CI/CD

#### 4.3 Encryption
- EBS volumes: Encrypted
- RDS: Encrypted at rest
- SSL/TLS: Required for all connections

### Phase 5: Monitoring & Logging

#### 5.1 CloudWatch
- EC2 metrics and logs
- ALB access logs
- RDS monitoring
- Custom dashboards

#### 5.2 Alerts
- Instance failures
- High CPU/memory usage
- Database connections
- SSL certificate expiration

### Phase 6: Testing & Validation

#### 6.1 Staging Tests
- Functional testing
- Performance testing
- Security scanning
- Database integrity checks

#### 6.2 Production Validation
- Smoke tests
- Traffic routing tests
- Rollback procedures
- Monitoring validation

## Implementation Timeline

### Week 1-2: Infrastructure Design
- [ ] Analyze existing infrastructure
- [ ] Design parallel environments
- [ ] Create Terraform modules
- [ ] Security review and approval

### Week 3-4: Core Infrastructure
- [ ] Deploy VPC and networking
- [ ] Create security groups and IAM
- [ ] Deploy RDS instances
- [ ] Configure monitoring

### Week 5-6: Application Environments
- [ ] Deploy EC2 instances
- [ ] Configure load balancers
- [ ] Set up auto-scaling
- [ ] Test basic connectivity

### Week 7-8: Migration Testing
- [ ] Database migration testing
- [ ] Application deployment testing
- [ ] Blue-green deployment testing
- [ ] Performance validation

## Cost Estimation

### Monthly Costs (Approximate)
- **EC2**: $10-50 per environment (t3.micro instances)
- **RDS**: $50-200 per environment (db.t3.micro)
- **EBS**: $5-20 per environment
- **ALB**: $20-30 per production environment
- **Data Transfer**: Variable based on traffic

### Total Parallel Environments
- 4 new environments: ~$300-600/month additional
- Database copies: One-time data transfer costs

## Risk Mitigation

### Rollback Strategy
- Keep existing environments untouched
- Implement proper backups before changes
- Test rollback procedures in staging

### Downtime Minimization
- Blue-green deployment for production
- Gradual traffic shifting
- Monitoring and alerting

### Security Considerations
- Least privilege access
- Encrypted communications
- Regular security updates

## Next Steps

1. **Infrastructure Review**: Validate current setup and requirements
2. **Resource Planning**: Confirm AWS account access and budgets
3. **Timeline Agreement**: Align on implementation schedule
4. **Kickoff**: Begin Phase 1 infrastructure planning

## Questions for Clarification

1. What are the specific Angular and Symfony versions being migrated to?
2. Are there any specific networking requirements (VPN, Direct Connect)?
3. What monitoring tools are currently in use?
4. Are there existing Terraform configurations to reference?
5. What are the database sizes and expected growth?

---

*This plan provides a comprehensive approach to creating parallel AWS environments for application migrations while maintaining the existing infrastructure.*
