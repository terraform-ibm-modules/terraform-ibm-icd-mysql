##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# ICD mysql database
##############################################################################

module "database" {
  source = "../.."
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source            = "terraform-ibm-modules/icd-mysql/ibm"
  # version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  resource_group_id   = module.resource_group.resource_group_id
  name                = "${var.prefix}-mysql"
  region              = var.region
  mysql_version       = var.mysql_version
  access_tags         = var.access_tags
  tags                = var.resource_tags
  service_endpoints   = var.service_endpoints
  member_host_flavor  = var.member_host_flavor
  deletion_protection = false
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
  count  = var.read_only_replicas_count
  source = "../.."
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source            = "terraform-ibm-modules/icd-mysql/ibm"
  # version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  resource_group_id   = module.resource_group.resource_group_id
  name                = "${var.prefix}-read-only-replica-${count.index}"
  region              = var.region
  tags                = var.resource_tags
  access_tags         = var.access_tags
  mysql_version       = var.mysql_version
  deletion_protection = false
  remote_leader_crn   = module.database.crn
  memory_mb           = 12288 # Must be an increment of 384 megabytes. The minimum size of a read-only replica is 12 GB RAM
  disk_mb             = 10240 # Must be an increment of 512 megabytes. The minimum size of a read-only replica is 10 GB of disk
  depends_on          = [time_sleep.wait_time]
}
