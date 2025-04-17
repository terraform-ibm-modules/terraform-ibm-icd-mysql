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
