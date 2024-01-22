##############################################################################
# Outputs
##############################################################################

output "pitr_mysql_db_id" {
  description = "PITR MySQL instance id"
  value       = module.mysql_db_pitr.id
}

output "pitr_mysql_db_version" {
  description = "PITR MySQL instance version"
  value       = module.mysql_db_pitr.version
}

output "pitr_time" {
  description = "PITR timestamp in UTC format (%Y-%m-%dT%H:%M:%SZ) used to create PITR instance"
  value       = var.pitr_time
}
