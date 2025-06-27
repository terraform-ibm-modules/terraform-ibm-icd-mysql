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
