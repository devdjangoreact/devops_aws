variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "deploy_dev" {
  description = "Whether to deploy the development environment"
  type        = bool
  default     = false
}

variable "deploy_staging" {
  description = "Whether to deploy the staging environment"
  type        = bool
  default     = false
}

variable "deploy_production" {
  description = "Whether to deploy the production environment (2 instances)"
  type        = bool
  default     = false
}

# AMI is now dynamically retrieved using data source in main.tf

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
  default     = "simple-ec2-instance"
}
