##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "MySQL instance id"
  value       = ibm_database.mysql_db.id
}

output "version" {
  description = "MySQL instance version"
  value       = ibm_database.mysql_db.version
}

output "guid" {
  description = "MySQL instance guid"
  value       = ibm_database.mysql_db.guid
}

output "crn" {
  description = "MySQL instance crn"
  value       = ibm_database.mysql_db.resource_crn
}

output "service_credentials_json" {
  description = "Service credentials json map"
  value       = local.service_credentials_json
  sensitive   = true
}

output "service_credentials_object" {
  description = "Service credentials object"
  value       = local.service_credentials_object
  sensitive   = true
}

output "cbr_rule_ids" {
  description = "CBR rule ids created to restrict MySQL access"
  value       = module.cbr_rule[*].rule_id
}

output "adminuser" {
  description = "Database admin user name"
  value       = ibm_database.mysql_db.adminuser
}

output "hostname" {
  description = "Database connection hostname"
  value       = data.ibm_database_connection.database_connection.mysql[0].hosts[0].hostname
}

output "port" {
  description = "Database connection port"
  value       = data.ibm_database_connection.database_connection.mysql[0].hosts[0].port
}

output "certificate_base64" {
  description = "Database connection certificate"
  value       = data.ibm_database_connection.database_connection.mysql[0].certificate[0].certificate_base64
  sensitive   = true
}
