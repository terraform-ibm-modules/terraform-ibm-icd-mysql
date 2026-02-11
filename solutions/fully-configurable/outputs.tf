##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "MySQL instance id"
  value       = local.mysql_id
}

output "version" {
  description = "MySQL instance version"
  value       = local.mysql_version
}

output "guid" {
  description = "MySQL instance guid"
  value       = local.mysql_guid
}

output "crn" {
  description = "MySQL instance crn"
  value       = local.mysql_crn
}

output "service_credentials_json" {
  description = "Service credentials json map"
  value       = var.existing_mysql_instance_crn != null ? null : module.mysql[0].service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "Service credentials object"
  value       = var.existing_mysql_instance_crn != null ? null : module.mysql[0].service_credentials_object
  sensitive   = true
}

output "hostname" {
  description = "Database connection hostname"
  value       = local.mysql_hostname
}

output "port" {
  description = "Database connection port"
  value       = local.mysql_port
}

output "secrets_manager_secrets" {
  description = "Service credential secrets"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secrets : null
}

output "next_steps_text" {
  value       = "Your Database for MySQL instance is ready. You can now take advantage of predictable performance, on-demand scaling, and robust security with our fully managed service"
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Deployment Details"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/services/databases-for-mysql/${local.mysql_crn}"
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "Learn more about Databases for MySQL"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/docs/databases-for-mysql"
  description = "Secondary URL"
}
