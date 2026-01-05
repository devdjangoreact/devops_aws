# EC2 Instance Module

# SSH Key Pair for EC2 access
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-ssh-key-${random_id.key_suffix.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Generate SSH private key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Random suffix for key name
resource "random_id" "key_suffix" {
  byte_length = 4
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.ec2_key.key_name

  user_data = var.user_data

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
