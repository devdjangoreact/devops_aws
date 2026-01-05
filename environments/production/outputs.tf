output "primary_instance_id" {
  description = "ID of the production primary EC2 instance"
  value       = module.ec2_instance_primary.instance_id
}

output "primary_instance_public_ip" {
  description = "Public IP address of the production primary EC2 instance"
  value       = module.ec2_instance_primary.instance_public_ip
}

output "primary_instance_state" {
  description = "Current state of the production primary EC2 instance"
  value       = module.ec2_instance_primary.instance_state
}

output "secondary_instance_id" {
  description = "ID of the production secondary EC2 instance"
  value       = module.ec2_instance_secondary.instance_id
}

output "secondary_instance_public_ip" {
  description = "Public IP address of the production secondary EC2 instance"
  value       = module.ec2_instance_secondary.instance_public_ip
}

output "secondary_instance_state" {
  description = "Current state of the production secondary EC2 instance"
  value       = module.ec2_instance_secondary.instance_state
}

output "ssh_private_key_primary" {
  description = "Private SSH key for connecting to the production primary instance"
  value       = module.ec2_instance_primary.ssh_private_key
  sensitive   = true
}

output "ssh_connection_command_primary" {
  description = "SSH command to connect to the production primary instance"
  value       = module.ec2_instance_primary.ssh_connection_command
}

output "ssh_private_key_secondary" {
  description = "Private SSH key for connecting to the production secondary instance"
  value       = module.ec2_instance_secondary.ssh_private_key
  sensitive   = true
}

output "ssh_connection_command_secondary" {
  description = "SSH command to connect to the production secondary instance"
  value       = module.ec2_instance_secondary.ssh_connection_command
}

output "ssh_key_download_command" {
  description = "Command to save SSH private keys to files for production"
  value       = "terraform output -raw ssh_private_key_primary > primary-key.pem && terraform output -raw ssh_private_key_secondary > secondary-key.pem && chmod 600 *.pem"
}

output "security_group_id" {
  description = "ID of the production security group"
  value       = module.networking.security_group_id
}
