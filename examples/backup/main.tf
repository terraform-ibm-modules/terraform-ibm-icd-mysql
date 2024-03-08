##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "mysql_db" {
  count             = var.mysql_db_backup_crn != null ? 0 : 1
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-mysql"
  mysql_version     = var.mysql_version
  region            = var.region
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
}

data "ibm_database_backups" "backup_database" {
  count         = var.mysql_db_backup_crn != null ? 0 : 1
  deployment_id = module.mysql_db[0].id
}

# New mysql instance pointing to the backup instance
module "restored_mysql_db" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-mysql-restored"
  mysql_version     = var.mysql_version
  region            = var.region
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  backup_crn        = var.mysql_db_backup_crn == null ? data.ibm_database_backups.backup_database[0].backups[0].backup_id : var.mysql_db_backup_crn
}
