##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.3.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}
data "ibm_database_backups" "backup_database" {
  deployment_id = var.existing_database_crn
}

# New mysql instance pointing to the backup instance
module "restored_mysql_db" {
  source = "../.."
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source            = "terraform-ibm-modules/icd-mysql/ibm"
  # version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  resource_group_id  = module.resource_group.resource_group_id
  name               = "${var.prefix}-mysql-restored"
  mysql_version      = var.mysql_version
  region             = var.region
  tags               = var.resource_tags
  access_tags        = var.access_tags
  member_host_flavor = "multitenant"
  backup_crn         = data.ibm_database_backups.backup_database.backups[0].backup_id
}
