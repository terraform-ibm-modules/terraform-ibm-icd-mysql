##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "MySQL instance id"
  value       = module.mysql_db.id
}

output "guid" {
  description = "MySQL instance guid"
  value       = module.mysql_db.guid
}

output "version" {
  description = "MySQL instance version"
  value       = module.mysql_db.version
}

output "crn" {
  description = "MySQL instance crn"
  value       = module.mysql_db.crn
}

output "adminuser" {
  description = "Database admin user name"
  value       = module.mysql_db.adminuser
}

output "hostname" {
  description = "Database connection hostname"
  value       = module.mysql_db.hostname
}

output "port" {
  description = "Database connection port"
  value       = module.mysql_db.port
}

output "certificate_base64" {
  description = "Database connection certificate"
  value       = module.mysql_db.certificate_base64
  sensitive   = true
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict MySQL"
  value       = module.mysql_db.cbr_rule_ids
}

output "service_credentials_json" {
  description = "Service credentials json map"
  value       = module.mysql_db.service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "Service credentials object"
  value       = module.mysql_db.service_credentials_object
  sensitive   = true
}
