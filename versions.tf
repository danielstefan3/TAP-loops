#-------------
# PIN VERSIONS
#-------------
terraform {
  # Terraform version
  required_version = ">=1.1.0"

  # Provider versions
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}