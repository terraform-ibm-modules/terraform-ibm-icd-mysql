##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "MySQL instance id"
  value       = module.mysql.id
}

output "version" {
  description = "MySQL instance version"
  value       = module.mysql.version
}

output "guid" {
  description = "MySQL instance guid"
  value       = module.mysql.guid
}

output "crn" {
  description = "MySQL instance crn"
  value       = module.mysql.crn
}

output "service_credentials_json" {
  description = "Service credentials json map"
  value       = module.mysql.service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "Service credentials object"
  value       = module.mysql.service_credentials_object
  sensitive   = true
}

output "hostname" {
  description = "Database connection hostname"
  value       = module.mysql.hostname
}

output "port" {
  description = "Database connection port"
  value       = module.mysql.port
}

output "secrets_manager_secrets" {
  description = "Service credential secrets"
  value       = module.mysql.secrets_manager_secrets
}

output "next_steps_text" {
  value       = module.mysql.next_steps_text
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = module.mysql.next_step_primary_label
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.mysql.next_step_primary_url
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = module.mysql.next_step_secondary_label
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = module.mysql.next_step_secondary_url
  description = "Secondary URL"
}
