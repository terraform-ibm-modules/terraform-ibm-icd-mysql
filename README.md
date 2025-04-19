# IBM Cloud Databases for MySQL module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-icd-mysql?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-icd-mysql/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This module implements an instance of the IBM Cloud Databases for MySQL service.

:exclamation: The module does not support major version upgrades or updates to encryption and backup encryption keys. To upgrade the version, create another instance of Databases for MySQL with the updated version and follow the steps in [Upgrading MySQL docs](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-mysql-upgrading) in the IBM Cloud Docs.


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-icd-mysql](#terraform-ibm-icd-mysql)
* [Submodules](./modules)
    * [fscloud](./modules/fscloud)
* [Examples](./examples)
    * [Basic with read-only replica example](./examples/basic)
    * [Complete example with BYOK encryption, CBR rules and VPE creation](./examples/complete)
    * [Financial Services Cloud profile example with autoscaling enabled](./examples/fscloud)
    * [Point in time recovery example (PITR)](./examples/pitr)
    * [Restore from backup example](./examples/backup)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-icd-mysql

### Usage

IBM Cloud Databases supports only Key Protect encryption for backups, not Hyper Protect Crypto Services. If you enable key management encryption and no value is passed for 'backup_encryption_key_crn', the value of 'kms_key_crn' is used. And if a HPCS value is set for `kms_key_crn`, the database backup encryption uses the default encryption keys. For more information, see [Hyper Protect Crypto Services Integration](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs) in the IBM Cloud Docs.

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

module "mysql_db" {
  source            = "terraform-ibm-modules/icd-mysql/ibm"
  version           = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  name              = "my-instance"
  region            = "us-south"
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Databases for MySQL** service
        - `Editor` role access

To attach access management tags to resources in this module, you need the following permissions.

- IAM Services
    - **Tagging** service
        - `Administrator` platform access


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup_key_crn_parser"></a> [backup\_key\_crn\_parser](#module\_backup\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.30.0 |
| <a name="module_kms_key_crn_parser"></a> [kms\_key\_crn\_parser](#module\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.1.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_database.mysql_db](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/database) | resource |
| [ibm_iam_authorization_policy.backup_kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_key.service_credentials](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.mysql_tag](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_backup_kms_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_database_connection.database_connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/database_connection) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the MySQL instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details | `list(string)` | `[]` | no |
| <a name="input_admin_pass"></a> [admin\_pass](#input\_admin\_pass) | The password for the database administrator. If the admin password is null then the admin user ID cannot be accessed. More users can be specified in a user block. | `string` | `null` | no |
| <a name="input_auto_scaling"></a> [auto\_scaling](#input\_auto\_scaling) | Optional rules to allow the database to increase resources in response to usage. Only a single autoscaling block is allowed. Make sure you understand the effects of autoscaling, especially for production environments. See https://ibm.biz/autoscaling-considerations in the IBM Cloud Docs. | <pre>object({<br/>    disk = object({<br/>      capacity_enabled             = optional(bool, false)<br/>      free_space_less_than_percent = optional(number, 10)<br/>      io_above_percent             = optional(number, 90)<br/>      io_enabled                   = optional(bool, false)<br/>      io_over_period               = optional(string, "15m")<br/>      rate_increase_percent        = optional(number, 10)<br/>      rate_limit_mb_per_member     = optional(number, 3670016)<br/>      rate_period_seconds          = optional(number, 900)<br/>      rate_units                   = optional(string, "mb")<br/>    })<br/>    memory = object({<br/>      io_above_percent         = optional(number, 90)<br/>      io_enabled               = optional(bool, false)<br/>      io_over_period           = optional(string, "15m")<br/>      rate_increase_percent    = optional(number, 10)<br/>      rate_limit_mb_per_member = optional(number, 114688)<br/>      rate_period_seconds      = optional(number, 900)<br/>      rate_units               = optional(string, "mb")<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_backup_crn"></a> [backup\_crn](#input\_backup\_crn) | The CRN of a backup resource to restore from. The backup is created by a database deployment with the same service ID. The backup is loaded after provisioning and the new deployment starts up that uses that data. A backup CRN is in the format crn:v1:<…>:backup:. If omitted, the database is provisioned empty. | `string` | `null` | no |
| <a name="input_backup_encryption_key_crn"></a> [backup\_encryption\_key\_crn](#input\_backup\_encryption\_key\_crn) | The CRN of a Key Protect or Hyper Protect Crypto Services encryption key that you want to use for encrypting the disk that holds deployment backups. Applies only if `use_ibm_owned_encryption_key` is false and `use_same_kms_key_for_backups` is false. If no value is passed, and `use_same_kms_key_for_backups` is true, the value of `kms_key_crn` is used. Alternatively set `use_default_backup_encryption_key` to true to use the IBM Cloud Databases default encryption. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups). | `string` | `null` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | (Optional, list) List of CBR rules to create | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | Database configuration parameters, see https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-changing-configuration&interface=api for more details. | <pre>object({<br/>    default_authentication_plugin      = optional(string) # sha256_password,caching_sha2_password,mysql_native_password<br/>    innodb_buffer_pool_size_percentage = optional(number) # 10 ≤ value ≤ 100<br/>    innodb_flush_log_at_trx_commit     = optional(number) # 0 ≤ value ≤ 2<br/>    innodb_log_buffer_size             = optional(number) # 1048576 ≤ value ≤ 4294967295<br/>    innodb_log_file_size               = optional(number) # 4194304 ≤ value ≤ 274877906900<br/>    innodb_lru_scan_depth              = optional(number) # 128 ≤ value ≤ 2048<br/>    innodb_read_io_threads             = optional(number) # 1 ≤ value ≤ 64<br/>    innodb_write_io_threads            = optional(number) # 1 ≤ value ≤ 64<br/>    max_allowed_packet                 = optional(number) # 1024 ≤ value ≤ 1073741824<br/>    max_connections                    = optional(number) # 100 ≤ value ≤ 200000<br/>    max_prepared_stmt_count            = optional(number) # 0 ≤ value ≤ 4194304<br/>    mysql_max_binlog_age_sec           = optional(number) # 300 ≤ value ≤ 1073741823 Default: 1800<br/>    net_read_timeout                   = optional(number) # 1 ≤ value ≤ 7200<br/>    net_write_timeout                  = optional(number) # 1 ≤ value ≤ 7200<br/>    sql_mode                           = optional(string) # The comma-separated list of SQL modes applied on this server globally<br/>    wait_timeout                       = optional(number) # 1 ≤ value ≤ 31536000<br/>  })</pre> | `null` | no |
| <a name="input_cpu_count"></a> [cpu\_count](#input\_cpu\_count) | Allocated dedicated CPU per member. For shared CPU, set to 0. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling) | `number` | `0` | no |
| <a name="input_disk_mb"></a> [disk\_mb](#input\_disk\_mb) | Allocated disk per member. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling) | `number` | `10240` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The CRN of a Key Protect or Hyper Protect Crypto Services encryption key to encrypt your data. Applies only if `use_ibm_owned_encryption_key` is false. By default this key is used for both deployment data and backups, but this behaviour can be altered using the `use_same_kms_key_for_backups` and `backup_encryption_key_crn` inputs. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups). | `string` | `null` | no |
| <a name="input_member_host_flavor"></a> [member\_host\_flavor](#input\_member\_host\_flavor) | Allocated host flavor per member. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/database#host_flavor). | `string` | `null` | no |
| <a name="input_members"></a> [members](#input\_members) | Allocated number of members. Members can be scaled up but not down. | `number` | `3` | no |
| <a name="input_memory_mb"></a> [memory\_mb](#input\_memory\_mb) | Allocated memory per-member. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-resources-scaling) | `number` | `4096` | no |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | Version of the MySQL instance to provision. If no value is passed, the current preferred version of IBM Cloud Databases is used. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name given to the MySQL instance. | `string` | n/a | yes |
| <a name="input_pitr_id"></a> [pitr\_id](#input\_pitr\_id) | (Optional) The ID of the source deployment MySQL instance that you want to recover back to. The MySQL instance is expected to be in an up and in running state. | `string` | `null` | no |
| <a name="input_pitr_time"></a> [pitr\_time](#input\_pitr\_time) | (Optional) The timestamp in UTC format (%Y-%m-%dT%H:%M:%SZ) for any time in the last 7 days that you want to restore to. To retrieve the timestamp, run the command (ibmcloud cdb mysql earliest-pitr-timestamp <deployment name or CRN>). For more info on Point-in-time Recovery, see https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-pitr | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where you want to deploy your instance. | `string` | `"us-south"` | no |
| <a name="input_remote_leader_crn"></a> [remote\_leader\_crn](#input\_remote\_leader\_crn) | A CRN of the leader database to make the replica(read-only) deployment. The leader database is created by a database deployment with the same service ID. A read-only replica is set up to replicate all of your data from the leader deployment to the replica deployment by using asynchronous replication. For more information, see https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-read-replicas | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where the MySQL instance will be created. | `string` | n/a | yes |
| <a name="input_service_credential_names"></a> [service\_credential\_names](#input\_service\_credential\_names) | Map of name, role for service credentials that you want to create for the database | `map(string)` | `{}` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Specify whether you want to enable the public, private, or both service endpoints. Supported values are 'public', 'private', or 'public-and-private'. | `string` | `"private"` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits all MySQL database instances in the resource group to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing\_kms\_instance\_guid variable. In addition, no policy is created if var.kms\_encryption\_enabled is set to false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional list of tags to be added to the MySQL instance. | `list(string)` | `[]` | no |
| <a name="input_use_default_backup_encryption_key"></a> [use\_default\_backup\_encryption\_key](#input\_use\_default\_backup\_encryption\_key) | When `use_ibm_owned_encryption_key` is set to false, backups will be encrypted with either the key specified in `kms_key_crn`, or in `backup_encryption_key_crn` if a value is passed. If you do not want to use your own key for backups encryption, you can set this to `true` to use the IBM Cloud Databases default encryption for backups. Alternatively set `use_ibm_owned_encryption_key` to true to use the default encryption for both backups and deployment data. | `bool` | `false` | no |
| <a name="input_use_ibm_owned_encryption_key"></a> [use\_ibm\_owned\_encryption\_key](#input\_use\_ibm\_owned\_encryption\_key) | IBM Cloud Databases will secure your deployment's data at rest automatically with an encryption key that IBM hold. Alternatively, you may select your own Key Management System instance and encryption key (Key Protect or Hyper Protect Crypto Services) by setting this to false. If setting to false, a value must be passed for the `kms_key_crn` input. | `bool` | `true` | no |
| <a name="input_use_same_kms_key_for_backups"></a> [use\_same\_kms\_key\_for\_backups](#input\_use\_same\_kms\_key\_for\_backups) | Set this to false if you wan't to use a different key that you own to encrypt backups. When set to false, a value is required for the `backup_encryption_key_crn` input. Alternatiely set `use_default_backup_encryption_key` to true to use the IBM Cloud Databases default encryption. Applies only if `use_ibm_owned_encryption_key` is false. Bare in mind that backups encryption is only available in certain regions. See [Bring your own key for backups](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-key-protect&interface=ui#key-byok) and [Using the HPCS Key for Backup encryption](https://cloud.ibm.com/docs/cloud-databases?topic=cloud-databases-hpcs#use-hpcs-backups). | `bool` | `true` | no |
| <a name="input_users"></a> [users](#input\_users) | A list of users that you want to create on the database. Multiple blocks are allowed. The user password must be in the range of 10-32 characters. Be warned that in most case using IAM service credentials (via the var.service\_credential\_names) is sufficient to control access to the MySQL instance. These blocks creates native MySQL database users, more info on that can be found here https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-user-management | <pre>list(object({<br/>    name     = string<br/>    password = string # pragma: allowlist secret<br/>    type     = optional(string)<br/>    role     = optional(string)<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_adminuser"></a> [adminuser](#output\_adminuser) | Database admin user name |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | CBR rule ids created to restrict MySQL access |
| <a name="output_certificate_base64"></a> [certificate\_base64](#output\_certificate\_base64) | Database connection certificate |
| <a name="output_crn"></a> [crn](#output\_crn) | MySQL instance crn |
| <a name="output_guid"></a> [guid](#output\_guid) | MySQL instance guid |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Database connection hostname |
| <a name="output_id"></a> [id](#output\_id) | MySQL instance id |
| <a name="output_port"></a> [port](#output\_port) | Database connection port |
| <a name="output_service_credentials_json"></a> [service\_credentials\_json](#output\_service\_credentials\_json) | Service credentials json map |
| <a name="output_service_credentials_object"></a> [service\_credentials\_object](#output\_service\_credentials\_object) | Service credentials object |
| <a name="output_version"></a> [version](#output\_version) | MySQL instance version |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
