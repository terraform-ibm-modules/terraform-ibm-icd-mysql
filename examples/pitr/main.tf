##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

# New ICD mysql database instance pointing to a PITR time
module "mysql_db_pitr" {
  source             = "../.."
  resource_group_id  = module.resource_group.resource_group_id
  name               = "${var.prefix}-mysql-pitr"
  region             = var.region
  tags               = var.resource_tags
  access_tags        = var.access_tags
  mysql_version      = var.mysql_version
  pitr_id            = var.pitr_id
  pitr_time          = var.pitr_time == "" ? " " : var.pitr_time
  member_host_flavor = "multitenant"
}
