##############################################################################
# Outputs
##############################################################################
output "id" {
  description = "MySQL instance id"
  value       = module.mysql.id
}

output "guid" {
  description = "MySQL instance guid"
  value       = module.mysql.guid
}

output "version" {
  description = "MySQL instance version"
  value       = module.mysql.version
}

output "hostname" {
  description = "MySQL instance hostname"
  value       = module.mysql.hostname
}

output "port" {
  description = "MySQL instance port"
  value       = module.mysql.port
}
