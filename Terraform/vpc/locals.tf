locals {
  name_prefix = "${var.environment}-vpc"

  common_tags = {
    Environment = var.environment
    Project     = "public-vpc"
    ManagedBy   = "Terraform"
  }
}