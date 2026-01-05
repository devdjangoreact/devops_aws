# Networking Module - Security Groups and related resources

# Security Group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name_prefix = var.security_group_name_prefix
  description = "Security group for EC2 instances with web and SSH access"

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Symfony API access
  ingress {
    description = "Symfony API"
    from_port   = 4444
    to_port     = 4444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Angular4 app access
  ingress {
    description = "Angular4 App"
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.security_group_name
    Environment = var.environment
  }
}

# Outputs
output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.ec2_sg.id
}
