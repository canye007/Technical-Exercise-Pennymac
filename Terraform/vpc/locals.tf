locals {
  name_prefix = "${var.environment}-vpc"

  common_tags = {
    Environment = var.environment
    Project     = "public-vpc"
    ManagedBy   = "Terraform"
  }
}

locals {
  lambda_name = "${var.environment}-${var.lambda_function_name}"
}

locals {
  az = "${var.aws_region}a"
}