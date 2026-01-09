# Terraform Infrastructure Module Structure

## Overview

This document describes the high-level Terraform module structure for the AWS infrastructure modernization. The infrastructure is organized using a modular approach with separate modules for each AWS service component, enabling better maintainability, reusability, and testing.

## Directory Structure

```
terraform/
├── main.tf                 # Root configuration and module instantiations
├── variables.tf            # Input variables for the entire infrastructure
├── outputs.tf              # Output values (endpoints, ARNs, etc.)
├── terraform.tfvars        # Environment-specific variable values
├── versions.tf             # Terraform and provider version constraints
├── providers.tf            # AWS provider configuration
├── data.tf                 # Data sources (existing resources, AMIs, etc.)
├── locals.tf               # Local values and computed variables
├── modules/                # Reusable modules directory
│   ├── vpc/               # Network infrastructure module
│   ├── ecs/               # ECS cluster and services module
│   ├── rds/               # Aurora database module
│   ├── redis/             # ElastiCache Redis module
│   ├── alb/               # Application Load Balancer module
│   ├── s3/                # S3 buckets and configurations
│   ├── ecr/               # Elastic Container Registry
│   ├── monitoring/        # CloudWatch alarms and dashboards
│   ├── iam/               # IAM roles and policies
│   └── security/          # Security groups and WAF rules
└── environments/          # Environment-specific configurations
    ├── staging/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── terraform.tfvars
    └── production/
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```

## Core Modules

### 1. VPC Module (`modules/vpc/`)

**Purpose:** Creates the network foundation with VPC, subnets, routing, and VPC endpoints.

**Resources Created:**
- VPC with configurable CIDR block
- Public and private subnets across 3 AZs
- Internet Gateway and NAT Gateways
- Route tables and route table associations
- VPC endpoints for S3, ECR, CloudWatch
- VPC flow logs

**Key Variables:**
- `vpc_cidr` - VPC CIDR block
- `public_subnets` - List of public subnet CIDRs
- `private_subnets` - List of private subnet CIDRs
- `availability_zones` - List of AZs to use

**Outputs:**
- `vpc_id` - VPC ID
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs
- `vpc_endpoint_s3_id` - S3 VPC endpoint ID

### 2. ECS Module (`modules/ecs/`)

**Purpose:** Manages ECS cluster, task definitions, and services for both frontend and backend applications.

**Resources Created:**
- ECS cluster with Fargate capacity provider
- Task definitions for frontend and backend services
- ECS services with auto-scaling policies
- CloudWatch log groups
- IAM roles for task execution

**Key Variables:**
- `cluster_name` - Name of the ECS cluster
- `frontend_image_uri` - ECR URI for frontend Docker image
- `backend_image_uri` - ECR URI for backend Docker image
- `desired_count_frontend` - Number of frontend tasks
- `desired_count_backend` - Number of backend tasks
- `cpu_frontend` - CPU units for frontend tasks
- `memory_frontend` - Memory for frontend tasks
- `cpu_backend` - CPU units for backend tasks
- `memory_backend` - Memory for backend tasks

**Outputs:**
- `cluster_id` - ECS cluster ID
- `frontend_service_name` - Frontend service name
- `backend_service_name` - Backend service name
- `task_execution_role_arn` - Task execution IAM role ARN

### 3. RDS Module (`modules/rds/`)

**Purpose:** Creates Aurora MySQL Serverless v2 cluster with read replicas.

**Resources Created:**
- Aurora MySQL cluster (Serverless v2)
- Cluster instances (writer and readers)
- DB subnet group
- DB parameter group
- Security group for database access
- CloudWatch alarms for monitoring

**Key Variables:**
- `cluster_identifier` - Unique identifier for the cluster
- `engine_version` - Aurora MySQL version
- `database_name` - Initial database name
- `master_username` - Master username
- `min_capacity` - Minimum Aurora Capacity Units
- `max_capacity` - Maximum Aurora Capacity Units
- `backup_retention_period` - Days to retain backups

**Outputs:**
- `cluster_endpoint` - Cluster endpoint for read/write
- `reader_endpoint` - Reader endpoint for read-only
- `cluster_arn` - Cluster ARN
- `database_name` - Database name

### 4. Redis Module (`modules/redis/`)

**Purpose:** Configures ElastiCache Redis cluster for caching.

**Resources Created:**
- Redis replication group
- Subnet group for Redis
- Security group
- Parameter group optimized for caching
- CloudWatch alarms

**Key Variables:**
- `cluster_id` - Redis cluster identifier
- `node_type` - Instance type (e.g., cache.t3.micro)
- `num_cache_clusters` - Number of cache clusters
- `parameter_group_name` - Parameter group name

**Outputs:**
- `primary_endpoint_address` - Primary Redis endpoint
- `reader_endpoint_address` - Reader Redis endpoint
- `port` - Redis port number

### 5. ALB Module (`modules/alb/`)

**Purpose:** Creates Application Load Balancer with target groups for blue-green deployments.

**Resources Created:**
- Application Load Balancer
- Target groups for blue and green environments
- Listener rules for path-based routing
- Security group for ALB
- CloudWatch alarms

**Key Variables:**
- `load_balancer_name` - Name of the load balancer
- `vpc_id` - VPC ID where ALB will be created
- `public_subnet_ids` - List of public subnet IDs
- `certificate_arn` - SSL certificate ARN
- `frontend_port` - Port for frontend service
- `backend_port` - Port for backend service

**Outputs:**
- `alb_dns_name` - ALB DNS name
- `alb_arn` - ALB ARN
- `blue_target_group_arn` - Blue target group ARN
- `green_target_group_arn` - Green target group ARN
- `listener_arn` - Listener ARN

### 6. S3 Module (`modules/s3/`)

**Purpose:** Creates S3 buckets for assets, logs, and backups with appropriate configurations.

**Resources Created:**
- S3 buckets with versioning
- Bucket policies
- Lifecycle configurations
- CORS configurations for assets bucket
- Replication configurations for backups

**Key Variables:**
- `assets_bucket_name` - Name for assets bucket
- `logs_bucket_name` - Name for logs bucket
- `backups_bucket_name` - Name for backups bucket
- `logs_retention_days` - Days to retain logs
- `backups_retention_days` - Days to retain backups

**Outputs:**
- `assets_bucket_id` - Assets bucket ID
- `logs_bucket_id` - Logs bucket ID
- `backups_bucket_id` - Backups bucket ID

### 7. ECR Module (`modules/ecr/`)

**Purpose:** Manages Elastic Container Registry repositories for Docker images.

**Resources Created:**
- ECR repositories for frontend and backend
- Repository policies
- Lifecycle policies to manage image retention
- Scan on push configurations

**Key Variables:**
- `frontend_repository_name` - Name for frontend repository
- `backend_repository_name` - Name for backend repository
- `image_tag_mutability` - IMMUTABLE or MUTABLE
- `scan_on_push` - Enable vulnerability scanning

**Outputs:**
- `frontend_repository_url` - Frontend repository URL
- `backend_repository_url` - Backend repository URL

### 8. Monitoring Module (`modules/monitoring/`)

**Purpose:** Sets up CloudWatch monitoring, alarms, and dashboards.

**Resources Created:**
- CloudWatch alarms for CPU, memory, and errors
- SNS topics for notifications
- CloudWatch dashboard
- Budget alarms

**Key Variables:**
- `alarm_email` - Email for alarm notifications
- `slack_webhook_url` - Slack webhook for notifications
- `budget_limit` - Monthly budget limit

**Outputs:**
- `sns_topic_arn` - SNS topic ARN for alarms
- `dashboard_url` - CloudWatch dashboard URL

### 9. IAM Module (`modules/iam/`)

**Purpose:** Creates IAM roles and policies for ECS tasks and CI/CD pipelines.

**Resources Created:**
- ECS task execution role
- ECS task role
- CodeBuild/CodePipeline roles
- Custom policies for S3, ECR, CloudWatch access

**Key Variables:**
- `environment` - Environment name (staging/production)
- `project_name` - Project identifier

**Outputs:**
- `task_execution_role_arn` - Task execution role ARN
- `task_role_arn` - Task role ARN
- `pipeline_role_arn` - CI/CD pipeline role ARN

### 10. Security Module (`modules/security/`)

**Purpose:** Configures security groups and network ACLs.

**Resources Created:**
- Security groups for ALB, ECS, RDS, Redis
- Network ACLs
- WAF rules (if needed)

**Key Variables:**
- `vpc_id` - VPC ID
- `alb_security_group_name` - ALB security group name
- `ecs_security_group_name` - ECS security group name
- `rds_security_group_name` - RDS security group name

**Outputs:**
- `alb_security_group_id` - ALB security group ID
- `ecs_security_group_id` - ECS security group ID
- `rds_security_group_id` - RDS security group ID

## Environment Configuration

### Staging Environment

```hcl
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr = "10.1.0.0/16"
  environment = "staging"
  # ... other variables
}

module "ecs" {
  source = "../modules/ecs"

  cluster_name = "lq3-staging"
  desired_count_frontend = 1
  desired_count_backend = 1
  # ... other variables
}
```

### Production Environment

```hcl
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  environment = "production"
  # ... other variables
}

module "ecs" {
  source = "../modules/ecs"

  cluster_name = "lq3-production"
  desired_count_frontend = 2
  desired_count_backend = 3
  # ... other variables
}
```

## State Management

**Backend Configuration:**
```hcl
terraform {
  backend "s3" {
    bucket         = "lq3-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Benefits of This Structure

- **Modularity:** Each component can be developed and tested independently
- **Reusability:** Modules can be reused across environments
- **Maintainability:** Clear separation of concerns
- **Scalability:** Easy to add new environments or regions
- **Testing:** Individual modules can be unit tested
- **CI/CD Integration:** Modules work well with automated deployment pipelines
