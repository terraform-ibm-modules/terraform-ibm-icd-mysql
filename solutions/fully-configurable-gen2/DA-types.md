# Configuring complex inputs in Databases for MySQL (Gen2)

Several optional input variables in the IBM Cloud [Databases for MySQL deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

- [Service credentials](#svc-credential-name) (`service_credential_names`)
- [Service credential secrets](#service-credential-secrets) (`service_credential_secrets`)
- [Configuration](#configuration) (`configuration`)

## Service credentials <a name="svc-credential-name"></a>

You can specify a set of IAM credentials to connect to the database with the `service_credential_names` input variable. Include a resource key name and IAM service role for each key. Each role provides a specific level of access to the database. For more information, see [Adding and viewing credentials](https://cloud.ibm.com/docs/account?topic=account-service_credentials&interface=ui). If you want to add service credentials to secret manager and to allow secret manager to manage it, you should use `service_credential_secrets`, see [Service credential secrets](#service-credential-secrets)

- Variable name: `service_credential_names`.
- Type: A list of objects that represent resource keys.
- Default value: An empty list (`[]`).

### Options for service_credential_names

- `name` (required): A unique human-readable name that identifies this resource key.
- `role` (optional, default = `Writer`): The IAM service role assigned to the credential. Valid values for Gen2 are `Manager` and `Writer`.
- `endpoint` (optional, default = `private`): The endpoint type for the resource key. For Gen2, this must be `private`.

### Example service credentials

```hcl
[
  {
    "name": "mysql-manager-resource-key",
    "role": "Manager",
    "endpoint": "private"
  },
  {
    "name": "mysql-writer-resource-key",
    "role": "Writer"
  }
]
```

## Service credential secrets <a name="service-credential-secrets"></a>

When you add an IBM Database for MySQL deployable architecture from the IBM Cloud catalog to IBM Cloud Project, you can configure service credentials. In edit mode for the projects configuration, from the configure panel click the optional tab.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the service credential secrets configurations to the array here.

In the configuration, specify the secret group name, whether it already exists or will be created and include all the necessary service credential secrets that need to be created within that secret group.

[Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/sm_service_credentials_secret) about service credential secrets.

- Variable name: `service_credential_secrets`.
- Type: A list of objects that represent a service credential secret groups and secrets
- Default value: An empty list (`[]`)

### Options for service_credential_secrets

- `secret_group_name` (required): A unique human-readable name that identifies this service credential secret group.
- `secret_group_description` (optional, default = `null`): A human-readable description for this secret group.
- `existing_secret_group`: (optional, default = `false`): Set to true, if secret group name provided in the variable `secret_group_name` already exists.
- `service_credentials`: (optional, default = `[]`): A list of object that represents a service credential secret.

#### Options for service_credentials

- `secret_name`: (required): A unique human-readable name of the secret to create.
- `service_credentials_source_service_role_crn`: (required): The CRN of the role to give the service credential in the IBM Cloud Database service. For Gen2, valid roles are `Manager` and `Writer`. Service credentials role CRNs can be found at https://cloud.ibm.com/iam/roles, select the IBM Cloud Database and select the role.
- `secret_labels`: (optional, default = `[]`): Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (|).
- `secret_auto_rotation`: (optional, default = `true`): Whether to configure automatic rotation of service credential.
- `secret_auto_rotation_unit`: (optional, default = `day`): Specifies the unit of time for rotation of a secret. Acceptable values are `day` or `month`.
- `secret_auto_rotation_interval`: (optional, default = `89`): Specifies the rotation interval for the rotation unit.
- `service_credentials_ttl`: (optional, default = `7776000`): The time-to-live (TTL) to assign to generated service credentials (in seconds).
- `service_credential_secret_description`: (optional, default = `null`): Description of the secret to create.

The following example includes all the configuration options for four service credentials and two secret groups.
```hcl
[
  {
    "secret_group_name": "sg-1"
    "existing_secret_group": true
    "service_credentials": [                                              # pragma: allowlist secret
      {
        "secret_name": "cred-1"
        "service_credentials_source_service_role_crn":  "crn:v1:bluemix:public:iam::::serviceRole:Manager"
        "secret_labels": ["test-manager-1", "test-manager-2"]
        "secret_auto_rotation": true
        "secret_auto_rotation_unit": "day"
        "secret_auto_rotation_interval": 89
        "service_credentials_ttl": 7776000
        "service_credential_secret_description": "sample description"
      },
      {
        "secret_name": "cred-2"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer"
      }
    ]
  },
  {
    "secret_group_name": "sg-2"
    "service_credentials": [                                              # pragma: allowlist secret
      {
        "secret_name": "cred-3"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer"
      }
    ]
  }
]
```

## Configuration  <a name="configuration"></a>

The Configuration variable tunes the MySQL database to suit different use cases. For more information, see [Configuration](https://cloud.ibm.com/docs/databases-for-mysql-gen2?topic=databases-for-mysql-gen2-configure-parameters&interface=cli).

- Variable name: `configuration`
- Type: An object with multiple attributes i.e. `default_authentication_plugin`, `innodb_buffer_pool_size_percentage`, `innodb_flush_log_at_trx_commit`, `innodb_log_buffer_size`, `innodb_log_file_size`, `innodb_lru_scan_depth`, `innodb_read_io_threads`, `innodb_write_io_threads`, `max_allowed_packet`, `max_connections`, `max_prepared_stmt_count`, `mysql_max_binlog_age_sec`, `net_read_timeout`, `net_write_timeout`, `sql_mode` and `wait_timeout`

### Options for configuration

The configuration object in the input contains the following options

**Available Settings. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql-gen2?topic=databases-for-mysql-gen2-configure-parameters&interface=cli#available-config-settings).**

- `default_authentication_plugin`: Allowable values are `sha256_password`, `caching_sha2_password` and `mysql_native_password`. Note: Unless strictly necessary, don't use `mysql_native_password`. (default: `sha256_password`).

- `innodb_buffer_pool_size_percentage`: The percentage of memory to use for innodb_buffer_pool_size. The default value of 50% is a conservative value and works for databases of any size. If your database requires more RAM, this value can be increased. Setting this value too high can exceed your database's memory limits, which can cause it to crash. (default: `50`).

- `innodb_flush_log_at_trx_commit`: Controls the balance between strict ACID compliance for commit operations and higher performance that is possible when commit-related I/O operations are rearranged and done in batches. You can achieve better performance by changing the default value but then you can lose transactions in a crash. (default: `2`).

- `innodb_log_buffer_size`: The size in bytes of the buffer that InnoDB uses to write to the log files on disk. (default: `33554432`).

- `innodb_log_file_size`: The size in bytes of each log file in a log group. Innodb_log_file_size and innodb_log_files_in_group have been superseded by innodb_redo_log_capacity. Setting innodb_log_file_size will also set innodb_redo_log_capacity. (default: `104857600`).

- `innodb_lru_scan_depth`: A parameter that influences the algorithms and heuristics for the flush operation for the InnoDB buffer pool. A setting smaller than the default is generally suitable for most workloads. A value that is much higher than necessary might impact performance. Consider increasing the value only if you have spare I/O capacity under a typical workload. (default: `256`).

- `innodb_read_io_threads`: The number of I/O threads for read operations in InnoDB. (default: `4`).

- `innodb_write_io_threads`: The number of I/O threads for write operations in InnoDB. (default: `4`).

- `max_allowed_packet`: (default: `16777216`).

- `max_connections`: (default: `200`).

- `max_prepared_stmt_count`: Specifies the total number of prepared statements on the server. (default: `16382`).

- `mysql_max_binlog_age_sec`: (default: `1800`).

- `net_read_timeout`: The number of seconds to wait for more data from a connection before aborting the read. (default: `60`).

- `net_write_timeout`: The number of seconds to wait for a block to be written to a connection before aborting the write. (default: `60`).

- `sql_mode`: Allowable values:
  - ALLOW_INVALID_DATES
  - ANSI_QUOTES
  - ERROR_FOR_DIVISION_BY_ZERO
  - HIGH_NOT_PRECEDENCE
  - IGNORE_SPACE
  - NO_AUTO_CREATE_USER
  - NO_AUTO_VALUE_ON_ZERO
  - NO_BACKSLASH_ESCAPES
  - NO_DIR_IN_CREATE
  - NO_ENGINE_SUBSTITUTION
  - NO_FIELD_OPTIONS
  - NO_KEY_OPTIONS
  - NO_TABLE_OPTIONS
  - NO_UNSIGNED_SUBTRACTION
  - NO_ZERO_DATE
  - NO_ZERO_IN_DATE
  - ONLY_FULL_GROUP_BY
  - PAD_CHAR_TO_FULL_LENGTH
  - PIPES_AS_CONCAT
  - REAL_AS_FLOAT
  - STRICT_ALL_TABLES
  - STRICT_TRANS_TABLES

- `wait_timeout`: The number of seconds the server waits for activity on a noninteractive connection before closing it. (default: `28800`).

### Example configuration

The following example shows values for the `configuration` input.

```hcl
{
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
    wait_timeout                       = 28800
}
```
