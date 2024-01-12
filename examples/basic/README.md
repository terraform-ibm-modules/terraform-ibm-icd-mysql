# Basic with read-only replica example

An end-to-end example that uses the module's default variable values. This example uses the IBM Cloud terraform provider to:

- Create a new resource group if one is not passed in.
- Create a new ICD MySQL database instance.
- Create a read-only replica of the leader MySQL database instance. For more info on Read-only Replicas, see [Configuring Read-only Replicas](https://cloud.ibm.com/docs/databases-for-mysql?topic=databases-for-mysql-read-replicas)
