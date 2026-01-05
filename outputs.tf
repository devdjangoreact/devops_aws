# Development Environment Outputs
output "dev_instance_public_ip" {
  description = "Public IP of the dev environment instance"
  value       = var.deploy_dev ? module.dev[0].instance_public_ip : null
}

output "dev_ssh_connection_command" {
  description = "SSH command for dev environment"
  value       = var.deploy_dev ? module.dev[0].ssh_connection_command : null
}

output "dev_application_urls" {
  description = "Application URLs for dev environment"
  value       = var.deploy_dev ? module.dev[0].application_urls : null
}

# Staging Environment Outputs
output "staging_instance_public_ip" {
  description = "Public IP of the staging environment instance"
  value       = var.deploy_staging ? module.staging[0].instance_public_ip : null
}

output "staging_ssh_connection_command" {
  description = "SSH command for staging environment"
  value       = var.deploy_staging ? module.staging[0].ssh_connection_command : null
}

output "staging_application_urls" {
  description = "Application URLs for staging environment"
  value       = var.deploy_staging ? module.staging[0].application_urls : null
}

# Production Environment Outputs (2 instances)
output "production_primary_instance_public_ip" {
  description = "Public IP of the production primary instance"
  value       = var.deploy_production ? module.production[0].primary_instance_public_ip : null
}

output "production_secondary_instance_public_ip" {
  description = "Public IP of the production secondary instance"
  value       = var.deploy_production ? module.production[0].secondary_instance_public_ip : null
}

output "production_ssh_connection_command_primary" {
  description = "SSH command for production primary instance"
  value       = var.deploy_production ? module.production[0].ssh_connection_command_primary : null
}

output "production_ssh_connection_command_secondary" {
  description = "SSH command for production secondary instance"
  value       = var.deploy_production ? module.production[0].ssh_connection_command_secondary : null
}

output "production_application_urls_primary" {
  description = "Application URLs for production primary instance"
  value = var.deploy_production ? {
    "Main Web Server" = "http://${module.production[0].primary_instance_public_ip}"
    "Symfony API"     = "http://${module.production[0].primary_instance_public_ip}:4444"
    "Angular4 App"    = "http://${module.production[0].primary_instance_public_ip}:5555"
  } : null
}

output "production_application_urls_secondary" {
  description = "Application URLs for production secondary instance"
  value = var.deploy_production ? {
    "Main Web Server" = "http://${module.production[0].secondary_instance_public_ip}"
    "Symfony API"     = "http://${module.production[0].secondary_instance_public_ip}:4444"
    "Angular4 App"    = "http://${module.production[0].secondary_instance_public_ip}:5555"
  } : null
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed environments"
  value = {
    dev_deployed         = var.deploy_dev
    staging_deployed     = var.deploy_staging
    production_deployed  = var.deploy_production
    total_environments   = (var.deploy_dev ? 1 : 0) + (var.deploy_staging ? 1 : 0) + (var.deploy_production ? 1 : 0)
    production_instances = var.deploy_production ? 2 : 0
  }
}
