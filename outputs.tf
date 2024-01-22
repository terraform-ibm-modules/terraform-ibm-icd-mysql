##############################################################################
# Outputs
##############################################################################

output "id" {
  description = "MySQL instance id"
  value       = ibm_database.mysql_db.id
}

output "guid" {
  description = "MySQL instance guid"
  value       = ibm_database.mysql_db.guid
}

output "version" {
  description = "MySQL instance version"
  value       = ibm_database.mysql_db.version
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

output "hostname" {
  description = "Database hostname. Only contains value when var.service_credential_names or var.users are set."
  value       = length(var.service_credential_names) > 0 ? nonsensitive(ibm_resource_key.service_credentials[keys(var.service_credential_names)[0]].credentials["connection.mysql.hosts.0.hostname"]) : length(var.users) > 0 ? data.ibm_database_connection.database_connection[0].mysql[0].hosts[0].hostname : null
}

output "port" {
  description = "Database port. Only contains value when var.service_credential_names or var.users are set."
  value       = length(var.service_credential_names) > 0 ? nonsensitive(ibm_resource_key.service_credentials[keys(var.service_credential_names)[0]].credentials["connection.mysql.hosts.0.port"]) : length(var.users) > 0 ? data.ibm_database_connection.database_connection[0].mysql[0].hosts[0].port : null
}
