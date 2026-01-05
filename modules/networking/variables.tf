variable "security_group_name_prefix" {
  description = "Prefix for security group name"
  type        = string
  default     = "ec2-sg-"
}

variable "security_group_name" {
  description = "Name tag for the security group"
  type        = string
  default     = "ec2-security-group"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "default"
}
