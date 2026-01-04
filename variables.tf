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

# AMI is now dynamically retrieved using data source in main.tf

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
  default     = "simple-ec2-instance"
}
