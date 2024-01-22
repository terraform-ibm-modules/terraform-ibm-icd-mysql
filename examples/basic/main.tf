##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.4"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# ICD mysql database
##############################################################################

module "mysql_db" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-mysql"
  mysql_version     = var.mysql_version
  region            = var.region
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
}

# On destroy, we are seeing that even though the replica has been returned as
# destroyed by terraform, the leader instance destroy can fail with: "You
# must delete all replicas before disabling the leader. Try again with valid
# values or contact support if the issue persists."
# The ICD team have recommended to wait for a period of time after the replica
# destroy completes before attempting to destroy the leader instance, so hence
# adding a time sleep here.

resource "time_sleep" "wait_time" {
  depends_on = [module.mysql_db]

  destroy_duration = "5m"
}

##############################################################################
# ICD mysql read-only-replica
##############################################################################

module "read_only_replica_mysql_db" {
  count             = var.read_only_replicas_count
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-read-only-replica-${count.index}"
  region            = var.region
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  mysql_version     = var.mysql_version
  remote_leader_crn = module.mysql_db.crn
  member_memory_mb  = 2304  # Must be an increment of 384 megabytes. The minimum size of a read-only replica is 2 GB RAM
  member_disk_mb    = 20480 # Must be an increment of 512 megabytes. The minimum size of a read-only replica is 20 GB of disk
  depends_on        = [time_sleep.wait_time]
}
