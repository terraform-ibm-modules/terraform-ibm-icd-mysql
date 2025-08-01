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

##############################################################################
# Key Protect All Inclusive
##############################################################################

locals {
  data_key_name    = "${var.prefix}-mysql"
  backups_key_name = "${var.prefix}-mysql-backups"
}

module "key_protect_all_inclusive" {
  source            = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version           = "5.1.14"
  resource_group_id = module.resource_group.resource_group_id
  # Note: Database instance and Key Protect must be created in the same region when using BYOK
  # See https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok
  region                    = var.region
  key_protect_instance_name = "${var.prefix}-kp"
  resource_tags             = var.resource_tags
  keys = [
    {
      key_ring_name = "icd-mysql"
      keys = [
        {
          key_name     = local.data_key_name
          force_delete = true
        },
        {
          key_name     = local.backups_key_name
          force_delete = true
        }
      ]
    }
  ]
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.25.13"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  tags              = var.resource_tags
}

##############################################################################
# Security group
##############################################################################

resource "ibm_is_security_group" "sg1" {
  name = "${var.prefix}-sg1"
  vpc  = module.vpc.vpc_id
}

# wait 30 secs after security group is destroyed before destroying VPE to workaround race condition
resource "time_sleep" "wait_30_seconds" {
  depends_on       = [ibm_is_security_group.sg1]
  destroy_duration = "30s"
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.32.6"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = module.vpc.vpc_crn,
  }]
}

##############################################################################
# MySQL Instance
##############################################################################

module "mysql_db" {
  source = "../../"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source            = "terraform-ibm-modules/icd-mysql/ibm"
  # version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-mysql"
  region            = var.region
  mysql_version     = var.mysql_version
  admin_pass        = var.admin_pass
  users             = var.users
  # Example of how to use different KMS keys for data and backups
  use_ibm_owned_encryption_key = false
  use_same_kms_key_for_backups = false
  kms_key_crn                  = module.key_protect_all_inclusive.keys["icd-mysql.${local.data_key_name}"].crn
  backup_encryption_key_crn    = module.key_protect_all_inclusive.keys["icd-mysql.${local.backups_key_name}"].crn
  service_credential_names = {
    "mysql_admin" : "Administrator",
    "mysql_operator" : "Operator",
    "mysql_viewer" : "Viewer",
    "mysql_editor" : "Editor",
  }
  tags               = var.resource_tags
  access_tags        = var.access_tags
  member_host_flavor = "multitenant"
  cbr_rules = [
    {
      description      = "${var.prefix}-mysql access only from vpc"
      enforcement_mode = "enabled" #mysql does not support report mode
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
}

# VPE provisioning should wait for the database provisioning
resource "time_sleep" "wait_120_seconds" {
  depends_on      = [module.mysql_db]
  create_duration = "120s"
}

##############################################################################
# VPE
##############################################################################

module "vpe" {
  source  = "terraform-ibm-modules/vpe-gateway/ibm"
  version = "4.7.0"
  prefix  = "vpe-to-my"
  cloud_service_by_crn = [
    {
      service_name = "${var.prefix}-mysql"
      crn          = module.mysql_db.crn
    },
  ]
  vpc_id             = module.vpc.vpc_id
  subnet_zone_list   = module.vpc.subnet_zone_list
  resource_group_id  = module.resource_group.resource_group_id
  security_group_ids = [ibm_is_security_group.sg1.id]
  depends_on = [
    time_sleep.wait_120_seconds,
    time_sleep.wait_30_seconds
  ]
}
