output "instance_id" {
  description = "ID of the dev EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the dev EC2 instance"
  value       = module.ec2_instance.instance_public_ip
}

output "instance_state" {
  description = "Current state of the dev EC2 instance"
  value       = module.ec2_instance.instance_state
}

output "ssh_private_key" {
  description = "Private SSH key for connecting to the dev instance"
  value       = module.ec2_instance.ssh_private_key
  sensitive   = true
}

output "ssh_connection_command" {
  description = "SSH command to connect to the dev instance"
  value       = module.ec2_instance.ssh_connection_command
}

output "ssh_key_download_command" {
  description = "Command to save SSH private key to file for dev"
  value       = module.ec2_instance.ssh_key_download_command
}

output "security_group_id" {
  description = "ID of the dev security group"
  value       = module.networking.security_group_id
}

output "application_urls" {
  description = "URLs to access the staging applications"
  value = {
    "Main Web Server" = "http://${module.ec2_instance.instance_public_ip}"
    "Symfony API"     = "http://${module.ec2_instance.instance_public_ip}:4444"
    "Angular4 App"    = "http://${module.ec2_instance.instance_public_ip}:5555"
  }
}
