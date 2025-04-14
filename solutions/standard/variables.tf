##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}
variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group to provision the Databases for MySQL in. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all resources created by this solution."
  default     = null
}

variable "name" {
  type        = string
  description = "The name of the Databases for MySQL instance. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "mysql"
}

variable "region" {
  description = "The region where you want to deploy your instance."
  type        = string
  default     = "us-south"
  validation {
    condition     = var.existing_mysql_instance_crn != null && var.region != local.existing_mysql_region ? false : true
    error_message = "The region detected in the 'existing_rabbitmq_instance_crn' value must match the value of the 'region' input variable when passing an existing instance."
  }
}

variable "existing_mysql_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing Databases for MySql instance. If no value is specified, a new instance is created."

  validation {
    condition     = var.existing_mysql_instance_crn != null ? true : var.use_ibm_owned_encryption_key && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null || var.existing_backup_kms_key_crn != null) ? false : true
    error_message = "When setting values for 'existing_kms_instance_crn', 'existing_kms_key_crn' or 'existing_backup_kms_key_crn', the 'use_ibm_owned_encryption_key' input must be set to false."
  }

  validation {
    condition     = var.existing_mysql_instance_crn != null ? true : !var.use_ibm_owned_encryption_key && (var.existing_kms_instance_crn == null && var.existing_kms_key_crn == null) ? false : true
    error_message = "When 'use_ibm_owned_encryption_key' is false, a value is required for either 'existing_kms_instance_crn' (to create a new key), or 'existing_kms_key_crn' to use an existing key."
  }
}

variable "remote_leader_crn" {
  type        = string
  description = "A CRN of the leader database to make the replica(read-only) deployment. The leader database is created by a database deployment with the same service ID. A read-only replica is set up to replicate all of your data from the leader deployment to the replica deployment by using asynchronous replication. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-read-replicas)"
  default     = null
}

variable "mysql_version" {
  description = "The version of the Databases for MySQL instance. If no value is specified, the current preferred version of Databases for MySQL is used."
  type        = string
  default     = null
}

##############################################################################
# ICD hosting model properties
##############################################################################

variable "members" {
  type        = number
  description = "The number of members that are allocated. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)."
  default     = 3
}

variable "member_memory_mb" {
  type        = number
  description = "The memory per member that is allocated. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)"
  default     = 4096
}

variable "member_cpu_count" {
  type        = number
  description = "The dedicated CPU per member that is allocated. For shared CPU, set to 0. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)."
  default     = 3
}

variable "member_disk_mb" {
  type        = number
  description = "The disk that is allocated per member. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling)."
  default     = 10240
}

variable "member_host_flavor" {
  type        = string
  description = "The host flavor per member. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/database#host_flavor)."
  default     = "multitenant"
}

variable "service_credential_names" {
  description = "Map of name, role for service credentials that you want to create for the database. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-icd-mysql/blob/main/solutions/standard/DA-types.md#svc-credential-name)"
  type        = map(string)
  default     = {}
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
    type     = string # "type" is required to generate the connection string for the outputs.
    role     = optional(string)
  }))
  default     = []
  sensitive   = true
  description = "A list of users that you want to create on the database. Users block is supported by MySQL version >= 6.0. Multiple blocks are allowed. The user password must be in the range of 10-32 characters. Be warned that in most case using IAM service credentials (via the var.service_credential_names) is sufficient to control access to the MySQL instance. This blocks creates native MySQL database users. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-icd-mysql/blob/main/solutions/standard/DA-types.md#users)"
}

variable "tags" {
  type        = list(any)
  description = "The list of tags to be added to the Databases for MySQL instance."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Databases for MySQL instance created by the solution. [Learn more](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial)."
  default     = []
}

variable "configuration" {
  description = "Database Configuration for MySQL instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-icd-mysql/tree/main/solutions/standard/DA-types.md)"
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
    sql_mode                           = optional(string) # The comma-separated list of SQL modes applied on this server globally.
    wait_timeout                       = optional(number) # 1 ≤ value ≤ 31536000
  })
  default = {
    default_authentication_plugin      = "sha256_password"
    innodb_buffer_pool_size_percentage = 50
    innodb_flush_log_at_trx_commit     = 2
    innodb_log_buffer_size             = 33554432
    innodb_log_file_size               = 104857600
    innodb_lru_scan_depth              = 256
    innodb_read_io_threads             = 4
    innodb_write_io_threads            = 4
    max_allowed_packet                 = 16777216
    max_connections                    = 200
    max_prepared_stmt_count            = 16382
    mysql_max_binlog_age_sec           = 1800
    net_read_timeout                   = 60
    net_write_timeout                  = 60
    # sql_mode No sensible default set of modes https://dev.mysql.com/doc/refman/8.0/en/sql-mode.html
    wait_timeout = 28800
  }
}

##############################################################
# Encryption
##############################################################

variable "use_ibm_owned_encryption_key" {
  type        = bool
  description = "IBM Cloud Databases will secure your deployment's data at rest automatically with an encryption key that IBM hold. Alternatively, you may select your own Key Management System instance and encryption key (Key Protect or Hyper Protect Crypto Services) by setting this to false. If setting to false, a value must be passed for `existing_kms_instance_crn` to create a new key, or `existing_kms_key_crn` and/or `existing_backup_kms_key_crn` to use an existing key."
  default     = false
}

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services instance. Required to create a new encryption key and key ring which will be used to encrypt both deployment data and backups. Applies only if `use_ibm_owned_encryption_key` is false. To use an existing key, pass values for `existing_kms_key_crn` and/or `existing_backup_kms_key_crn`. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups)."
  default     = null
  validation {
    condition     = (var.existing_kms_instance_crn == null) == var.use_ibm_owned_encryption_key
    error_message = "If 'existing_kms_instance_crn' is provided, 'use_ibm_owned_encryption_key' must be set to false."
  }
}

variable "existing_kms_key_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services encryption key to encrypt your data. Applies only if `use_ibm_owned_encryption_key` is false. By default this key is used for both deployment data and backups, but this behaviour can be altered using the optional `existing_backup_kms_key_crn` input. If no value is passed a new key will be created in the instance specified in the `existing_kms_instance_crn` input. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups)."
  default     = null
  validation {
    condition     = (var.existing_kms_key_crn == null && var.existing_kms_instance_crn == null) == var.use_ibm_owned_encryption_key
    error_message = "'use_ibm_owned_encryption_key' input must be set to false."
  }
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use for communicating with the Key Protect or Hyper Protect Crypto Services instance. Possible values: `public`, `private`. Applies only if `existing_kms_key_crn` is not specified."
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "The kms_endpoint_type value must be 'public' or 'private'."
  }
}

variable "skip_mysql_kms_auth_policy" {
  type        = bool
  description = "Whether to create an IAM authorization policy that permits all Databases for MySQL instances in the resource group to read the encryption key from the Hyper Protect Crypto Services instance specified in the `existing_kms_instance_crn` variable."
  default     = false
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the MySQL instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null
}

variable "key_ring_name" {
  type        = string
  default     = "mysql-key-ring"
  description = "The name for the key ring created for the Databases for MySQL key. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "key_name" {
  type        = string
  default     = "mysql-key"
  description = "The name for the key created for the Databases for MySQL key. Applies only if not specifying an existing key. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
}

variable "existing_backup_kms_key_crn" {
  type        = string
  description = "The CRN of a Key Protect or Hyper Protect Crypto Services encryption key that you want to use for encrypting the disk that holds deployment backups. Applies only if `use_ibm_owned_encryption_key` is false. If no value is passed, the value of `existing_kms_key_crn` is used. If no value is passed for `existing_kms_key_crn`, a new key will be created in the instance specified in the `existing_kms_instance_crn` input. Alternatively set `use_default_backup_encryption_key` to true to use the IBM Cloud Databases default encryption. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups)."
  default     = null
  validation {
    condition     = var.existing_backup_kms_key_crn == null || var.use_ibm_owned_encryption_key == false
    error_message = "'use_ibm_owned_encryption_key' input must be set to false."
  }
}

variable "use_default_backup_encryption_key" {
  type        = bool
  description = "When `use_ibm_owned_encryption_key` is set to false, backups will be encrypted with either the key specified in `existing_kms_key_crn`, in `existing_backup_kms_key_crn`, or with a new key that will be created in the instance specified in the `existing_kms_instance_crn` input. If you do not want to use your own key for backups encryption, you can set this to `true` to use the IBM Cloud Databases default encryption for backups. Alternatively set `use_ibm_owned_encryption_key` to true to use the default encryption for both backups and deployment data."
  default     = false
}

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
variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
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
  description = "Optional rules to allow the database to increase resources in response to usage. Only a single autoscaling block is allowed. Make sure you understand the effects of autoscaling, especially for production environments. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-icd-mysql/blob/main/solutions/standard/DA-types.md#autoscaling)"
  default     = null
}

##############################################################################
## Secrets Manager Service Credentials
##############################################################################

variable "existing_secrets_manager_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of existing secrets manager to use to create service credential secrets for Databases for MySQL instance."

  validation {
    condition     = var.existing_secrets_manager_instance_crn != null && var.admin_pass_secret_manager_secret_group == null ? false : true
    error_message = "`admin_pass_secret_manager_secret_group` is required when `existing_secrets_manager_instance_crn` is set."
  }

  validation {
    condition     = var.existing_secrets_manager_instance_crn != null && var.admin_pass_secret_manager_secret_name == null ? false : true
    error_message = "`admin_pass_secrets_manager_secret_name` is required when `existing_secrets_manager_instance_crn` is set."
  }

  validation {
    condition     = length(var.service_credential_secrets) > 0 && var.existing_secrets_manager_instance_crn == null ? false : true
    error_message = "`existing_secrets_manager_instance_crn` is required when adding service credentials to a secrets manager secret."
  }
}

variable "existing_secrets_manager_endpoint_type" {
  type        = string
  description = "The endpoint type to use if `existing_secrets_manager_instance_crn` is specified. Possible values: public, private."
  default     = "private"
  validation {
    condition     = contains(["public", "private"], var.existing_secrets_manager_endpoint_type)
    error_message = "Only \"public\" and \"private\" are allowed values for 'existing_secrets_endpoint_type'."
  }
}

variable "service_credential_secrets" {
  type = list(object({
    secret_group_name        = string
    secret_group_description = optional(string)
    existing_secret_group    = optional(bool)
    service_credentials = list(object({
      secret_name                                 = string
      service_credentials_source_service_role_crn = string
      secret_labels                               = optional(list(string))
      secret_auto_rotation                        = optional(bool)
      secret_auto_rotation_unit                   = optional(string)
      secret_auto_rotation_interval               = optional(number)
      service_credentials_ttl                     = optional(string)
      service_credential_secret_description       = optional(string)

    }))
  }))
  default     = []
  description = "Service credential secrets configuration for Databases for MySQL. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-icd-mysql/tree/main/solutions/standard/DA-types.md#service-credential-secrets)."

  validation {
    # Service roles CRNs can be found at https://cloud.ibm.com/iam/roles, select the IBM Cloud Database and select the role
    condition = alltrue([
      for group in var.service_credential_secrets : alltrue([
        # crn:v?:bluemix; two non-empty segments; three possibly empty segments; :serviceRole or role: non-empty segment
        for credential in group.service_credentials : can(regex("^crn:v[0-9]:bluemix(:..*){2}(:.*){3}:(serviceRole|role):..*$", credential.service_credentials_source_service_role_crn))
      ])
    ])
    error_message = "service_credentials_source_service_role_crn must be a serviceRole CRN. See https://cloud.ibm.com/iam/roles"
  }
}

variable "skip_mysql_sm_auth_policy" {
  type        = bool
  default     = false
  description = "Whether an IAM authorization policy is created for Secrets Manager instance to create a service credential secrets for Databases for MySQL. If set to false, the Secrets Manager instance passed by the user is granted the Key Manager access to the MySQL instance created by the Deployable Architecture. Set to `true` to use an existing policy. The value of this is ignored if any value for 'existing_secrets_manager_instance_crn' is not passed."
}

variable "admin_pass_secret_manager_secret_group" {
  type        = string
  description = "The name of a new or existing secrets manager secret group for admin password. To use existing secret group, `use_existing_admin_pass_sm_secret_group` must be set to `true`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "mysql-secrets"
}

variable "use_existing_admin_pass_secret_manager_secret_group" {
  type        = bool
  description = "Whether to use an existing secrets manager secret group for admin password."
  default     = false
}

variable "admin_pass_secret_manager_secret_name" {
  type        = string
  description = "The name of a new redis administrator secret. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "mysql-admin-password"
}
