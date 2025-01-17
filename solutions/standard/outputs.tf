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

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict MySQL"
  value       = module.mysql.cbr_rule_ids
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

output "adminuser" {
  description = "Database admin user name"
  value       = module.mysql.adminuser
}

output "hostname" {
  description = "Database connection hostname"
  value       = module.mysql.hostname
}

output "port" {
  description = "Database connection port"
  value       = module.mysql.port
}

output "certificate_base64" {
  description = "Database connection certificate"
  value       = module.mysql.certificate_base64
  sensitive   = true
}

output "secrets_manager_secrets" {
  description = "Service credential secrets"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secrets : null
}
