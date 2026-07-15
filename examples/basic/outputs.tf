##############################################################################
# Outputs
##############################################################################
output "id" {
  description = "Database instance id"
  value       = module.database.id
}

output "mysql_crn" {
  description = "Mysql CRN"
  value       = module.database.crn
}

output "version" {
  description = "MySQL instance version"
  value       = module.database.version
}

output "adminuser" {
  description = "Database admin user name"
  value       = module.database.adminuser
}

output "hostname" {
  description = "Database connection hostname"
  value       = module.database.hostname
}

output "port" {
  description = "Database connection port"
  value       = module.database.port
}

output "certificate_base64" {
  description = "Database connection certificate"
  value       = module.database.certificate_base64
  sensitive   = true
}

output "read_replica_ids" {
  description = "Read-only replica MySQL instance IDs"
  value       = local.is_gen2 ? null : module.read_only_replica_mysql_db[*].id
}

output "read_replica_crns" {
  description = "Read-only replica MySQL CRNs"
  value       = local.is_gen2 ? null : module.read_only_replica_mysql_db[*].crn
}
