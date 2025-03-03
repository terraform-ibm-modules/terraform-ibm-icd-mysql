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

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict MySQL"
  value       = module.mysql[0].cbr_rule_ids
}

output "service_credentials_json" {
  description = "Service credentials json map"
  value       = module.mysql[0].service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "Service credentials object"
  value       = module.mysql[0].service_credentials_object
  sensitive   = true
}

output "adminuser" {
  description = "Database admin user name"
  value       = module.mysql[0].adminuser
}

output "hostname" {
  description = "Database connection hostname"
  value       = local.mysql_hostname
}

output "port" {
  description = "Database connection port"
  value       = local.mysql_port
}

output "certificate_base64" {
  description = "Database connection certificate"
  value       = local.mysql_cert
  sensitive   = true
}

output "secrets_manager_secrets" {
  description = "Service credential secrets"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secrets : null
}
