 # IBM Cloud Databases for MySQL

This architecture creates an instance of IBM Cloud Databases for MySQL and supports provisioning of the following resources:

- A resource group, if one is not passed in.
- A KMS root key, if one is not passed in.
- An IBM Cloud Databases for MySQL instance with KMS encryption.
- Autoscaling rules for the database instance, if provided.
- Service credential secrets and store them in secret manager.

![fscloud-mysql](../../reference-architecture/deployable-architecture-mysql.svg)

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
