variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "mysql-res"
}

variable "mysql_version" {
  description = "Version of the MySQL instance. If no value passed, the current ICD preferred version is used."
  type        = string
  default     = null
}

variable "plan" {
  type        = string
  description = "The name of the service plan that you choose for your MySQL instance. Use a `-gen2` plan (e.g. `standard-gen2`) to restore a Gen2 backup."
  default     = "standard"
}

variable "disk_mb" {
  type        = number
  description = "The disk that is allocated per member. [Learn more](https://cloud.ibm.com/docs/databases-for-mysql-gen2?topic=databases-for-mysql-gen2-resources-scaling&interface=ui)"
  default     = 10240
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the MySQL instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details"
  default     = []
}

variable "existing_database_crn" {
  type        = string
  description = "The existing CRN of a MySQL instance to fetch the latest backup CRN from."
  default     = null
}
