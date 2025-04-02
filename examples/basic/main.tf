##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# ICD mysql database
##############################################################################

module "database" {
  source             = "../.."
  resource_group_id  = module.resource_group.resource_group_id
  name               = "${var.prefix}-mysql"
  mysql_version      = var.mysql_version
  region             = var.region
  access_tags        = var.access_tags
  service_endpoints  = var.service_endpoints
  tags               = var.resource_tags
  member_host_flavor = var.member_host_flavor
  service_credential_names = {
    "mysql_admin" : "Administrator",
    "mysql_operator" : "Operator",
    "mysql_viewer" : "Viewer",
    "mysql_editor" : "Editor",
  }
}

# On destroy, we are seeing that even though the replica has been returned as
# destroyed by terraform, the leader instance destroy can fail with: "You
# must delete all replicas before disabling the leader. Try again with valid
# values or contact support if the issue persists."
# The ICD team have recommended to wait for a period of time after the replica
# destroy completes before attempting to destroy the leader instance, so hence
# adding a time sleep here.

resource "time_sleep" "wait_time" {
  depends_on = [module.database]

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
  tags              = var.resource_tags
  access_tags       = var.access_tags
  mysql_version     = var.mysql_version
  remote_leader_crn = module.database.crn
  memory_mb         = 12288 # Must be an increment of 384 megabytes. The minimum size of a read-only replica is 12 GB RAM
  disk_mb           = 10240 # Must be an increment of 512 megabytes. The minimum size of a read-only replica is 10 GB of disk
  depends_on        = [time_sleep.wait_time]
}
