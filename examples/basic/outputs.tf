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
