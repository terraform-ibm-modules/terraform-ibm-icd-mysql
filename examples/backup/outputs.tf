##############################################################################
# Outputs
##############################################################################
output "id" {
  description = "MySQL instance id"
  value       = var.mysql_db_backup_crn == null ? module.mysql_db[0].id : null
}

output "restored_mysql_db_id" {
  description = "Restored MySQL instance id"
  value       = module.restored_mysql_db.id
}

output "restored_mysql_db_version" {
  description = "Restored MySQL instance version"
  value       = module.restored_mysql_db.version
}
