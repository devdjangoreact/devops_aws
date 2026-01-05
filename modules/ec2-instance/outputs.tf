output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.ec2_instance.instance_state
}

output "ssh_private_key" {
  description = "Private SSH key for connecting to the instance"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <key-file> ec2-user@${aws_instance.ec2_instance.public_ip}"
}

output "ssh_key_download_command" {
  description = "Command to save SSH private key to file"
  value       = "terraform output -raw ssh_private_key > ec2-ssh-key.pem && chmod 600 ec2-ssh-key.pem"
}
