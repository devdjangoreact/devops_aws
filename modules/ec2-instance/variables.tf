variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
  default     = "simple-ec2-instance"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "default"
}

variable "security_group_id" {
  description = "Security group ID to attach to the instance"
  type        = string
}

variable "user_data" {
  description = "User data script for instance initialization"
  type        = string
  default     = ""
}
