##############################################################################
# Input Variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where the MySQL instance will be created."
}

variable "name" {
  type        = string
  description = "The name given to the MySQL instance."
}

variable "mysql_version" {
  type        = string
  description = "Version of the MySQL instance to provision. If no value is passed, the current preferred version of IBM Cloud Databases is used."
  default     = null

  validation {
    condition = anytrue([
      var.mysql_version == null,
      var.mysql_version == "8.0"
    ])
    error_message = "Version must be 8.0. If no value passed, the current ICD preferred version is used."
  }
}

variable "region" {
  type        = string
  description = "The region to provision all resources in. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/region) about how to select different regions for different services."
  default     = "us-south"
}

variable "remote_leader_crn" {
  type        = string
  description = "A CRN of the leader database to make the replica(read-only) deployment. The leader database is created by a database deployment with the same service ID. A read-only replica is set up to replicate all of your data from the leader deployment to the replica deployment by using asynchronous replication. For more information, see https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-read-replicas"
  default     = null
}

##############################################################################
# ICD hosting model properties
##############################################################################

variable "members" {
  type        = number
  description = "Allocated number of members. Members can be scaled up but not down."
  default     = 3
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "cpu_count" {
  type        = number
  description = "Allocated dedicated CPU per member. For shared CPU, set to 0. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)"
  default     = 0
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "disk_mb" {
  type        = number
  description = "Allocated disk per member. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)"
  default     = 10240
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "member_host_flavor" {
  type        = string
  description = "Allocated host flavor per member. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/database#host_flavor)."
  default     = null
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "memory_mb" {
  type        = number
  description = "Allocated memory per-member. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)"
  default     = 4096
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "admin_pass" {
  type        = string
  description = "The password for the database administrator. If the admin password is null then the admin user ID cannot be accessed. More users can be specified in a user block."
  default     = null
  sensitive   = true
}

variable "users" {
  type = list(object({
    name     = string
    password = string # pragma: allowlist secret
    type     = optional(string)
    role     = optional(string)
  }))
  description = "A list of users that you want to create on the database. Multiple blocks are allowed. The user password must be in the range of 10-32 characters. Be warned that in most case using IAM service credentials (via the var.service_credential_names) is sufficient to control access to the MySQL instance. These blocks creates native MySQL database users, more info on that can be found here https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-user-management"
  default     = []
  sensitive   = true
}

variable "service_credential_names" {
  type        = map(string)
  description = "Map of name, role for service credentials that you want to create for the database"
  default     = {}

  validation {
    condition     = alltrue([for name, role in var.service_credential_names : contains(["Administrator", "Operator", "Viewer", "Editor"], role)])
    error_message = "Valid values for service credential roles are 'Administrator', 'Operator', 'Viewer', and `Editor`"
  }
}

variable "service_endpoints" {
  type        = string
  description = "Specify whether you want to enable the public, private, or both service endpoints. Supported values are 'public', 'private', or 'public-and-private'."
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
    error_message = "Valid values for service_endpoints are 'public', 'public-and-private', and 'private'"
  }
}

variable "tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the MySQL instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the MySQL instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\", see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits for more details"
  }
}

variable "configuration" {
  type = object({
    default_authentication_plugin      = optional(string) # sha256_password,caching_sha2_password,mysql_native_password
    innodb_buffer_pool_size_percentage = optional(number) # 10 ≤ value ≤ 100
    innodb_flush_log_at_trx_commit     = optional(number) # 0 ≤ value ≤ 2
    innodb_log_buffer_size             = optional(number) # 1048576 ≤ value ≤ 4294967295
    innodb_log_file_size               = optional(number) # 4194304 ≤ value ≤ 274877906900
    innodb_lru_scan_depth              = optional(number) # 128 ≤ value ≤ 2048
    innodb_read_io_threads             = optional(number) # 1 ≤ value ≤ 64
    innodb_write_io_threads            = optional(number) # 1 ≤ value ≤ 64
    max_allowed_packet                 = optional(number) # 1024 ≤ value ≤ 1073741824
    max_connections                    = optional(number) # 100 ≤ value ≤ 200000
    max_prepared_stmt_count            = optional(number) # 0 ≤ value ≤ 4194304
    mysql_max_binlog_age_sec           = optional(number) # 300 ≤ value ≤ 1073741823 Default: 1800
    net_read_timeout                   = optional(number) # 1 ≤ value ≤ 7200
    net_write_timeout                  = optional(number) # 1 ≤ value ≤ 7200
    sql_mode                           = optional(string) # The comma-separated list of SQL modes applied on this server globally
    wait_timeout                       = optional(number) # 1 ≤ value ≤ 31536000
  })
  description = "Database configuration parameters, see https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-changing-configuration&interface=api for more details."
  default     = null

  validation {
    condition     = var.configuration != null ? (var.configuration["default_authentication_plugin"] != null ? contains(["sha256_password", "caching_sha2_password", "mysql_native_password"], var.configuration["default_authentication_plugin"]) : true) : true
    error_message = "Value for `configuration[\"default_authentication_plugin\"]` must be one of `sha256_password`, `caching_sha2_password`, or `mysql_native_password`, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_buffer_pool_size_percentage"] != null ? (var.configuration["innodb_buffer_pool_size_percentage"] >= 10 && var.configuration["innodb_buffer_pool_size_percentage"] <= 100) : true) : true
    error_message = "Value for `configuration[\"innodb_buffer_pool_size_percentage\"]` must be 10 ≤ value ≤ 100, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_flush_log_at_trx_commit"] != null ? (var.configuration["innodb_flush_log_at_trx_commit"] >= 0 && var.configuration["innodb_flush_log_at_trx_commit"] <= 2) : true) : true
    error_message = "Value for `configuration[\"innodb_flush_log_at_trx_commit\"]` must be 0 ≤ value ≤ 2, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_log_buffer_size"] != null ? (var.configuration["innodb_log_buffer_size"] >= 1048576 && var.configuration["innodb_log_buffer_size"] <= 4294967295) : true) : true
    error_message = "Value for `configuration[\"innodb_log_buffer_size\"]` must be 1048576 ≤ value ≤ 4294967295, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_log_file_size"] != null ? (var.configuration["innodb_log_file_size"] >= 4194304 && var.configuration["innodb_log_file_size"] <= 274877906900) : true) : true
    error_message = "Value for `configuration[\"innodb_log_file_size\"]` must be 4194304 ≤ value ≤ 274877906900, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_lru_scan_depth"] != null ? (var.configuration["innodb_lru_scan_depth"] >= 128 && var.configuration["innodb_lru_scan_depth"] <= 2048) : true) : true
    error_message = "Value for `configuration[\"innodb_lru_scan_depth\"]` must be 128 ≤ value ≤ 2048, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_read_io_threads"] != null ? (var.configuration["innodb_read_io_threads"] >= 1 && var.configuration["innodb_read_io_threads"] <= 64) : true) : true
    error_message = "Value for `configuration[\"innodb_read_io_threads\"]` must be 1 ≤ value ≤ 64, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["innodb_write_io_threads"] != null ? (var.configuration["innodb_write_io_threads"] >= 1 && var.configuration["innodb_write_io_threads"] <= 64) : true) : true
    error_message = "Value for `configuration[\"innodb_write_io_threads\"]` must be 1 ≤ value ≤ 64, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["max_allowed_packet"] != null ? (var.configuration["max_allowed_packet"] >= 1024 && var.configuration["max_allowed_packet"] <= 1073741824) : true) : true
    error_message = "Value for `configuration[\"max_allowed_packet\"]` must be 1024 ≤ value ≤ 1073741824, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["max_connections"] != null ? (var.configuration["max_connections"] >= 100 && var.configuration["max_connections"] <= 200000) : true) : true
    error_message = "Value for `configuration[\"max_connections\"]` must be 100 ≤ value ≤ 200000, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["max_prepared_stmt_count"] != null ? (var.configuration["max_prepared_stmt_count"] >= 0 && var.configuration["max_prepared_stmt_count"] <= 4194304) : true) : true
    error_message = "Value for `configuration[\"max_prepared_stmt_count\"]` must be 0 ≤ value ≤ 4194304, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["mysql_max_binlog_age_sec"] != null ? (var.configuration["mysql_max_binlog_age_sec"] >= 300 && var.configuration["mysql_max_binlog_age_sec"] <= 1073741823) : true) : true
    error_message = "Value for `configuration[\"mysql_max_binlog_age_sec\"]` must be 300 ≤ value ≤ 1073741823, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["net_read_timeout"] != null ? (var.configuration["net_read_timeout"] >= 1 && var.configuration["net_read_timeout"] <= 7200) : true) : true
    error_message = "Value for `configuration[\"net_read_timeout\"]` must be 1 ≤ value ≤ 7200, if specified."
  }

  validation {
    condition     = var.configuration != null ? (var.configuration["net_write_timeout"] != null ? (var.configuration["net_write_timeout"] >= 1 && var.configuration["net_write_timeout"] <= 7200) : true) : true
    error_message = "Value for `configuration[\"net_write_timeout\"]` must be 1 ≤ value ≤ 7200, if specified."
  }

  #  sql_mode = optional(string) # The comma-separated list of SQL modes applied on this server globally.

  validation {
    condition     = var.configuration != null ? (var.configuration["wait_timeout"] != null ? (var.configuration["wait_timeout"] >= 1 && var.configuration["wait_timeout"] <= 31536000) : true) : true
    error_message = "Value for `configuration[\"wait_timeout\"]` must be 1 ≤ value ≤ 31536000, if specified."
  }
}

##############################################################
# Auto Scaling
##############################################################

variable "auto_scaling" {
  type = object({
    disk = object({
      capacity_enabled             = optional(bool, false)
      free_space_less_than_percent = optional(number, 10)
      io_above_percent             = optional(number, 90)
      io_enabled                   = optional(bool, false)
      io_over_period               = optional(string, "15m")
      rate_increase_percent        = optional(number, 10)
      rate_limit_mb_per_member     = optional(number, 3670016)
      rate_period_seconds          = optional(number, 900)
      rate_units                   = optional(string, "mb")
    })
    memory = object({
      io_above_percent         = optional(number, 90)
      io_enabled               = optional(bool, false)
      io_over_period           = optional(string, "15m")
      rate_increase_percent    = optional(number, 10)
      rate_limit_mb_per_member = optional(number, 114688)
      rate_period_seconds      = optional(number, 900)
      rate_units               = optional(string, "mb")
    })
  })
  description = "Optional rules to allow the database to increase resources in response to usage. Only a single autoscaling block is allowed. Make sure you understand the effects of autoscaling, especially for production environments. See https://ibm.biz/autoscaling-considerations in the IBM Cloud Docs."
  default     = null
}

##############################################################
# Encryption
##############################################################

variable "kms_encryption_enabled" {
  type        = bool
  description = "Set to true to enable KMS Encryption using customer managed keys. When set to true, a value must be passed for either 'existing_kms_instance_crn', 'existing_kms_key_crn' or 'existing_backup_kms_key_crn'."
  default     = false
}

variable "use_ibm_owned_encryption_key" {
  type        = bool
  description = "IBM Cloud Databases will secure your deployment's data at rest automatically with an encryption key that IBM hold. Alternatively, you may select your own Key Management System instance and encryption key (Key Protect or Hyper Protect Crypto Services) by setting this to false. If setting to false, a value must be passed for the `kms_key_crn` input."
  default     = true

  validation {
    condition = !(
      var.use_ibm_owned_encryption_key == true &&
      (var.kms_key_crn != null || var.backup_encryption_key_crn != null)
    )
    error_message = "When 'use_ibm_owned_encryption_key' is true, 'kms_key_crn' and 'backup_encryption_key_crn' must both be null."
  }

  validation {
    condition     = var.use_ibm_owned_encryption_key || var.kms_key_crn != null
    error_message = "When setting 'use_ibm_owned_encryption_key' to false, a value must be passed for 'kms_key_crn'."
  }

  validation {
    condition = (
      var.use_ibm_owned_encryption_key ||
      var.backup_encryption_key_crn == null ||
      (!var.use_default_backup_encryption_key && !var.use_same_kms_key_for_backups)
    )
    error_message = "When passing a value for 'backup_encryption_key_crn' you cannot set 'use_default_backup_encryption_key' to true or 'use_ibm_owned_encryption_key' to false."
  }

  validation {
    condition = (
      var.use_ibm_owned_encryption_key ||
      var.backup_encryption_key_crn != null ||
      var.use_same_kms_key_for_backups
    )
    error_message = "When 'use_same_kms_key_for_backups' is set to false, a value needs to be passed for 'backup_encryption_key_crn'."
  }
}

variable "use_default_backup_encryption_key" {
  type        = bool
  description = "When `use_ibm_owned_encryption_key` is set to false, backups will be encrypted with either the key specified in `kms_key_crn`, or in `backup_encryption_key_crn` if a value is passed. If you do not want to use your own key for backups encryption, you can set this to `true` to use the IBM Cloud Databases default encryption for backups. Alternatively set `use_ibm_owned_encryption_key` to true to use the default encryption for both backups and deployment data."
  default     = false
}

variable "kms_key_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services encryption key to encrypt your data. Applies only if `use_ibm_owned_encryption_key` is false. By default this key is used for both deployment data and backups, but this behaviour can be altered using the `use_same_kms_key_for_backups` and `backup_encryption_key_crn` inputs. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups)."
  default     = null

  validation {
    condition = anytrue([
      var.kms_key_crn == null,
      can(regex(".*kms.*", var.kms_key_crn)),
      can(regex(".*hs-crypto.*", var.kms_key_crn)),
    ])
    error_message = "Value must be the KMS key CRN from a Key Protect or Hyper Protect Crypto Services instance."
  }
}

variable "use_same_kms_key_for_backups" {
  type        = bool
  description = "Set this to false if you wan't to use a different key that you own to encrypt backups. When set to false, a value is required for the `backup_encryption_key_crn` input. Alternatiely set `use_default_backup_encryption_key` to true to use the IBM Cloud Databases default encryption. Applies only if `use_ibm_owned_encryption_key` is false. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups)."
  default     = true
}

variable "backup_encryption_key_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services encryption key that you want to use for encrypting the disk that holds deployment backups. Applies only if `use_ibm_owned_encryption_key` is false and `use_same_kms_key_for_backups` is false. If no value is passed, and `use_same_kms_key_for_backups` is true, the value of `kms_key_crn` is used. Alternatively set `use_default_backup_encryption_key` to true to use the IBM Cloud Databases default encryption. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups)."
  default     = null

  validation {
    condition = anytrue([
      var.backup_encryption_key_crn == null,
      can(regex(".*kms.*", var.backup_encryption_key_crn)),
      can(regex(".*hs-crypto.*", var.backup_encryption_key_crn)),
    ])
    error_message = "Value must be the KMS key CRN from a Key Protect or Hyper Protect Crypto Services instance in one of the supported backup regions."
  }
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits all MySQL database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing_kms_instance_guid variable. In addition, no policy is created if var.kms_encryption_enabled is set to false."
  default     = false
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    tags = optional(list(object({
      name  = string
      value = string
    })))
  }))
  description = "(Optional, list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}

##############################################################
# Backup
##############################################################

variable "backup_crn" {
  type        = string
  description = "The CRN of a backup resource to restore from. The backup is created by a database deployment with the same service ID. The backup is loaded after provisioning and the new deployment starts up that uses that data. A backup CRN is in the format crn:v1:<…>:backup:. If omitted, the database is provisioned empty."
  default     = null

  validation {
    condition = anytrue([
      var.backup_crn == null,
      can(regex("^crn:.*:backup:", var.backup_crn))
    ])
    error_message = "backup_crn must be null OR starts with 'crn:' and contains ':backup:'"
  }
}

##############################################################
# Point-In-Time Recovery (PITR)
##############################################################

variable "pitr_id" {
  type        = string
  description = "(Optional) The ID of the source deployment MySQL instance that you want to recover back to. The MySQL instance is expected to be in an up and in running state."
  default     = null

  validation {
    condition     = var.pitr_id != null ? true : var.pitr_time == null
    error_message = "To use Point-In-Time Recovery (PITR), a value for var.pitr_id needs to be set when var.pitr_time is specified. Otherwise, unset var.pitr_time."
  }

  validation {
    condition     = var.pitr_id == null ? true : var.pitr_time != null
    error_message = "To use Point-In-Time Recovery (PITR), a value for var.pitr_time needs to be set when var.pitr_id is specified. Otherwise, unset var.pitr_id."
  }
}

variable "pitr_time" {
  type        = string
  description = "(Optional) The timestamp in UTC format (%Y-%m-%dT%H:%M:%SZ) for any time in the last 7 days that you want to restore to. To retrieve the timestamp, run the command (ibmcloud cdb mysql earliest-pitr-timestamp <deployment name or CRN>). For more info on Point-in-time Recovery, see https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-pitr"
  default     = null
}
