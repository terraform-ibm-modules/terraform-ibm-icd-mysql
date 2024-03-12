##############################################################################
# Outputs
##############################################################################
output "id" {
  description = "MySQL instance id"
  value       = module.mysql_db.id
}

output "version" {
  description = "MySQL instance version"
  value       = module.mysql_db.version
}

output "adminuser" {
  description = "Database admin user name"
  value       = module.mysql_db.adminuser
}

output "hostname" {
  description = "Database hostname"
  value       = module.mysql_db.hostname
}

output "port" {
  description = "Database port"
  value       = module.mysql_db.port
}

output "certificate_base64" {
  description = "Database port"
  value       = module.mysql_db.certificate_base64
  sensitive   = true
}
