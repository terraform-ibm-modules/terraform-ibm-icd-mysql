terraform {
  required_version = ">= 1.3.0, <1.7.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.61.0, < 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
