# AWS Production Infrastructure Architecture - Modernized Design

![Production Architecture](image/prod.svg)

## Overview

This document describes the complete production infrastructure architecture for the LQ3 project after modernization. The design leverages AWS managed services to achieve high availability, cost efficiency, and simplified operations while maintaining Docker-based application deployment.

## Architecture Components

### 1. Traffic Ingress & Load Balancing Layer

**Cloudflare (External)**

- Primary Functions: CDN, WAF, DDoS protection, SSL termination
- Routing: All traffic passes through Cloudflare before reaching AWS
- Benefits: Improved security, caching, and global distribution

**Application Load Balancer (ALB)**

- Type: Application Load Balancer (internet-facing)
- ARN: arn:aws:elasticloadbalancing:us-west-2:...
- Routing Rules:
  - Path: / → Frontend Target Group
  - Path: /api/* → Backend API Target Group
- Features:
  - SSL termination (TLS 1.2/1.3)
  - Health checks on all targets
  - Access logging to S3
  - Cross-zone load balancing enabled

**Target Groups (Blue/Green Deployment)**

- Target Group Blue: Active production environment (100% traffic)
- Target Group Green: Standby/new version environment (0% traffic initially)
- Configuration:
  - Port: 3000 (Frontend), 8000 (Backend)
  - Protocol: HTTP/HTTPS
  - Health check path: /health or /api/health
  - Deregistration delay: 30 seconds (for connection draining)

### 2. Compute Layer - ECS Fargate

**ECS Cluster: lq3-production**

- Capacity Provider: AWS Fargate (serverless compute)
- Region: us-west-2 (Oregon)
- Availability: Multi-AZ deployment across 3 availability zones
- Cluster Features:
  - Container Insights enabled
  - CloudWatch Logs integration
  - IAM roles for tasks

**Frontend Service - Angular Application 1**

- Service Name: frontend-app1
- Task Configuration:
  - CPU: 1 vCPU (1024 units)
  - Memory: 2 GB
  - Desired Count: 2 tasks (minimum for HA)
  - Auto-scaling: 2-8 tasks based on CPU utilization (70% threshold)
- Docker Image: ECR/frontend:latest with Angular 4-20 version support
- Port Mapping: 3000:3000
- Health Check: HTTP GET /

**Frontend Service - Angular Application 2**

- Service Name: frontend-app2
- Task Configuration:
  - CPU: 1 vCPU (1024 units)
  - Memory: 2 GB
  - Desired Count: 2 tasks
  - Auto-scaling: 2-8 tasks based on request count (>1000 RPM)
- Environment Variables:
  - API_ENDPOINT: http://backend-service
  - NODE_ENV: production
  - ANGULAR_VERSION: configurable per deployment

**Backend Service - Symfony API**

- Service Name: backend-api
- Task Configuration:
  - CPU: 2 vCPU (2048 units)
  - Memory: 4 GB
  - Desired Count: 3 tasks (minimum for load distribution)
  - Auto-scaling: 3-12 tasks based on CPU (70%) and memory (80%)
- Docker Image: ECR/backend:latest with PHP 7.4-8.2 support
- Port Mapping: 8000:8000
- Health Check: HTTP GET /api/health
- Environment Variables:
  - DATABASE_URL: aurora connection string
  - REDIS_URL: redis endpoint
  - APP_ENV: prod

### 3. Database Layer - Aurora MySQL

**Aurora MySQL Serverless v2 Cluster**

- Engine: Aurora MySQL 8.0
- Capacity Mode: Serverless v2
- Scaling Configuration:
  - Minimum ACU: 2 (Aurora Capacity Units)
  - Maximum ACU: 8
  - Auto-pause: 5 minutes of inactivity

**Instances:**

- Writer Instance: Primary read/write endpoint
- Reader Instance 1: Read replica in AZ-a
- Reader Instance 2: Read replica in AZ-b

**Storage:**

- Type: Aurora Storage Cluster
- Initial Size: 100 GB
- Auto-grow: Enabled (up to 128 TB)
- Multi-AZ: Automatic 6-way replication

**Database Features**

- Backup: Automated daily snapshots + Point-in-Time Recovery (35 days)
- Encryption: AES-256 at rest, SSL in transit
- Monitoring: Enhanced Monitoring with 1-second granularity
- Performance Insights: Enabled with 7-day retention
- Parameter Group: Custom optimized for Symfony applications

### 4. Caching Layer - ElastiCache Redis

**Redis Cluster Configuration**

- Engine: Redis 7.0
- Node Type: cache.t3.micro (cost-optimized)
- Architecture: Primary with 2 read replicas
- Features:
  - Multi-AZ with automatic failover
  - Data persistence (RDB snapshots every 24h)
  - In-transit and at-rest encryption
- Configuration:
  - Port: 6379
  - Maxmemory policy: allkeys-lru
  - Notifications: keyspace events enabled

### 5. Storage Layer

**Amazon S3 Buckets**

- **lq3-assets:** Static files, user uploads, Angular build artifacts
  - Versioning: Enabled
  - Lifecycle: Transition to Glacier after 90 days
  - CORS: Configured for web access
  - Encryption: SSE-S3 default encryption

- **lq3-logs:** ALB access logs, CloudTrail logs, application logs
  - Lifecycle: Delete after 90 days (reduced from 1.4TB indefinite)
  - Partitioning: Year/month/day/hour structure

- **lq3-backups:** Database snapshots, ECR image backups
  - Versioning: Enabled
  - Lifecycle: Delete after 30 days
  - Cross-region replication: Enabled for DR

**Amazon ECR Repositories**

- **frontend-images:** Docker images for Angular applications
  - Tag immutability: Enabled
  - Scan on push: Vulnerability scanning
  - Lifecycle: Keep last 10 images

- **backend-images:** Docker images for Symfony API
  - Supports multiple PHP versions (7.4, 8.0, 8.1, 8.2)
  - Multi-architecture: AMD64 and ARM64

### 6. Networking & Security

**VPC Architecture**

- CIDR Block: 10.0.0.0/16

**Public Subnets (3 AZs):**

- 10.0.1.0/24 (us-west-2a) - ALB, NAT Gateway
- 10.0.2.0/24 (us-west-2b) - ALB
- 10.0.3.0/24 (us-west-2c) - ALB

**Private Subnets (3 AZs):**

- 10.0.10.0/24 (us-west-2a) - ECS Tasks
- 10.0.20.0/24 (us-west-2b) - ECS Tasks, RDS
- 10.0.30.0/24 (us-west-2c) - ECS Tasks, Redis

**Security Configuration**

- **Security Groups:**
  - ecs-tasks-sg: Ports 3000, 8000 from ALB only
  - rds-sg: Port 3306 from ECS tasks only
  - redis-sg: Port 6379 from ECS tasks only
  - alb-sg: Ports 80, 443 from Cloudflare IP ranges only

- Network ACLs: Default allow all within VPC, deny external

**VPC Endpoints:**

- S3 Gateway Endpoint (reduces NAT Gateway costs)
- ECR API and Docker endpoints
- CloudWatch Logs endpoint

### 7. Monitoring & Observability

**CloudWatch**

- **Metrics:**
  - ECS: CPUUtilization, MemoryUtilization, RunningTaskCount
  - RDS: DatabaseConnections, CPUUtilization, FreeableMemory
  - ALB: RequestCount, TargetResponseTime, HTTPCode_ELB_5XX_Count
  - ElastiCache: CPUUtilization, CacheHits, CacheMisses

- **Alarms:**
  - High CPU (>70% for 5 minutes) - triggers scaling
  - High memory (>80% for 5 minutes) - triggers scaling
  - Health check failures (>2 in 5 minutes) - triggers task replacement
  - Cost alerts (80%, 90%, 100% of $1000 budget)

- **Logs:**
  - Log Group: /ecs/lq3-production
  - Retention: 30 days (reduced from indefinite)
  - Metric filters for error patterns

**AWS X-Ray**

- Enabled: For distributed tracing
- Sampling: 1 request per second, 5% of additional requests
- Integration: ECS, ALB, and application-level tracing

**Slack Integration**

- SNS Topics: For deployment notifications, alarms
- Lambda Functions: Transform and forward to Slack webhooks
- Channels:
  - #deployments: Start/end of deployments
  - #alerts: Critical infrastructure alerts
  - #costs: Budget threshold notifications

### 8. CI/CD Pipeline Integration

**Bitbucket Pipelines**

- Triggers: Push to main/staging branches, pull request updates
- Stages:
  - Build: Node/Angular and PHP/Symfony builds
  - Test: Unit, integration, security scans
  - Docker Build: Multi-version Docker images
  - Push to ECR: Tag with commit hash and branch
  - Terraform Plan: Infrastructure changes preview
  - ECS Deploy: Blue-green deployment execution

- Variables:
  - AWS credentials via OIDC (no stored secrets)
  - Environment-specific configurations
  - Version matrix for Angular/PHP

**Terraform Infrastructure**

- Backend: S3 bucket with DynamoDB locking
- Modules:
  - Network (VPC, subnets, routing)
  - ECS (cluster, services, tasks)
  - RDS (Aurora cluster, parameter groups)
  - Redis (ElastiCache cluster)
  - Monitoring (alarms, dashboards)
- State Management: Separate state files per environment

### 9. Blue-Green Deployment Process

**Deployment Flow**

- **Initial State:**
  - BLUE target group: 100% traffic, running version N
  - GREEN target group: 0% traffic, no tasks

- **Deploy to GREEN:**
  - New tasks launched with version N+1
  - Health checks pass before proceeding
  - Smoke tests executed automatically

- **Traffic Shift (gradual):**
  - 10% traffic to GREEN for 5 minutes
  - Monitor metrics and error rates
  - 50% traffic to GREEN for 5 minutes
  - 100% traffic to GREEN

- **Verification:**
  - Automated post-deployment tests
  - Manual verification if configured
  - Monitor for 15 minutes

- **Cleanup:**
  - Drain connections from BLUE tasks
  - Stop BLUE tasks
  - Update GREEN to become new BLUE for next deployment

**Rollback Procedure**

- Immediate: Switch 100% traffic back to BLUE
- Investigation: GREEN tasks remain running for debugging
- Cleanup: Stop GREEN tasks after issue resolution

### 10. Auto-scaling Configuration

**ECS Service Scaling**

- **Frontend Scaling:**
  - Scale-out: CPU > 70% for 2 minutes
  - Scale-in: CPU < 30% for 5 minutes
  - Cooldown: 60 seconds between scaling actions

- **Backend Scaling:**
  - Scale-out: RequestCount > 1000 per minute per task
  - Memory-based: MemoryUtilization > 80% for 2 minutes
  - Step scaling: Add 1 task initially, then 2 if needed

**Aurora Serverless Scaling**

- Scale-out: When CPU > 70% or connections > 80% of max
- Scale-in: After 15 minutes of low utilization
- Maximum: 8 ACU during business hours, 2 ACU at night

### 11. Cost Optimization Features

**Scheduled Operations**

- Dev Environments: Auto-stop at 7 PM, auto-start at 7 AM
- RDS Instances: Reader replicas scale to zero overnight
- Backup Windows: During low-usage hours (2 AM - 4 AM)

**Rightsizing**

- ECS Tasks: Regular analysis of CPU/memory utilization
- RDS: Performance Insights for query optimization
- Storage: Lifecycle policies for S3 and EBS

**Budget Controls**

- Monthly Budget: $1000 with 3-tier alerts
- Cost Explorer: Daily review of service costs
- Anomaly Detection: Automatic alerts for unusual spending

### 12. Disaster Recovery & Backup

**Backup Strategy**

- RDS: Automated daily snapshots + PITR (35 days retention)
- ECR Images: Automated weekly backups to S3
- Configuration: Terraform state and parameter backups

**Recovery Procedures**

- RDS Recovery: Point-in-time restore within 35 days
- ECS Recovery: Redeploy from ECR images (5-minute RTO)
- Data Corruption: Restore from yesterday's snapshot

**Multi-Region Considerations**

- S3 Replication: Critical data replicated to us-east-1
- ECR Replication: Production images replicated to secondary region
- Route53: DNS failover configuration (future enhancement)

## Benefits Delivered

### Cost Efficiency (Target: <$1000/month)

- **RDS:** Serverless scaling saves ~60% vs. fixed instances
- **Compute:** Fargate pay-per-use vs. EC2 always-on
- **Networking:** VPC endpoints eliminate NAT Gateway costs
- **Storage:** Optimized retention policies reduce S3 costs

### Operational Simplicity

- **No EC2 Management:** Fargate handles all infrastructure
- **Automated Deployments:** One-click from Bitbucket
- **Self-healing:** Automatic task replacement
- **Unified Monitoring:** Single CloudWatch dashboard

### Reliability & Performance

- **High Availability:** Multi-AZ across all services
- **Zero-downtime Deployments:** Blue-green with gradual traffic shift
- **Auto-scaling:** Handles traffic spikes automatically
- **Performance Optimization:** Aurora read replicas, Redis caching

### Security & Compliance

- **Network Isolation:** All workloads in private subnets
- **Encryption:** Data encrypted at rest and in transit
- **Least Privilege:** IAM roles with minimal permissions
- **Audit Trail:** CloudTrail logging for all API calls

### Developer Experience

- **Fast Deployments:** 10-15 minutes from commit to production
- **Easy Rollbacks:** One-click revert to previous version
- **Environment Parity:** Identical staging and production
- **Comprehensive Logs:** Centralized logging with search

## Migration Path

This architecture can be deployed in parallel with existing infrastructure, allowing gradual migration and testing without impacting current production systems. The Terraform configuration enables easy replication for staging environments and future expansion.
