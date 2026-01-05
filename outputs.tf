output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.simple_ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.simple_ec2.public_ip
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.simple_ec2.instance_state
}

output "docker_setup_info" {
  description = "Information about Docker setup"
  value       = "Docker and Docker Compose are installed. Nginx web server container is running on port 80."
}

output "ssh_private_key" {
  description = "Private SSH key for connecting to the instance"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <key-file> ec2-user@${aws_instance.simple_ec2.public_ip}"
}

output "ssh_key_download_command" {
  description = "Command to save SSH private key to file"
  value       = "terraform output -raw ssh_private_key > ec2-ssh-key.pem && chmod 600 ec2-ssh-key.pem"
}

output "security_group_id" {
  description = "ID of the security group attached to the instance"
  value       = aws_security_group.ec2_sg.id
}

output "open_ports" {
  description = "Open ports on the instance"
  value       = "22 (SSH), 80 (HTTP), 443 (HTTPS), 4444 (Symfony API), 5555 (Angular4 App)"
}

output "application_urls" {
  description = "URLs to access the running applications"
  value = {
    "Main Web Server" = "http://${aws_instance.simple_ec2.public_ip}"
    "Symfony API"     = "http://${aws_instance.simple_ec2.public_ip}:4444"
    "Angular4 App"    = "http://${aws_instance.simple_ec2.public_ip}:5555"
  }
}
