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

output "hostname" {
  description = "MySQL instance hostname"
  value       = module.mysql_db.hostname
}

output "port" {
  description = "MySQL instance port"
  value       = module.mysql_db.port
}
