# -------------------------------------------
# Terraform block declaring required provider
# -------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Version constraint/limit
    }
  }
}

# This block sets the region
provider "aws" {
  region = var.aws_region
}
