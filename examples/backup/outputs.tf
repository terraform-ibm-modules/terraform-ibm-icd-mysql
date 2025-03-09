##############################################################################
# Outputs
##############################################################################
output "restored_mysql_db_id" {
  description = "Restored MySQL instance id"
  value       = module.restored_mysql_db.id
}

output "restored_mysql_db_version" {
  description = "Restored MySQL instance version"
  value       = module.restored_mysql_db.version
}
