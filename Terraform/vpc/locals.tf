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
locals {
  cleanup_lambda_name  = "${var.environment}-snapshot-cleanup"
  report_lambda_name   = "${var.environment}-snapshot-report"
}
locals {
  sns_topic_name = "${var.environment}-snapshot-report-topic"
}
# locals {
#   unique_suffix = random_id.suffix.hex
# }
locals {
  name_prefix   = "${var.environment}-vpc"
  unique_suffix = random_id.suffix.hex

  common_tags = {
    Environment = var.environment
    Project     = "public-vpc"
    ManagedBy   = "Terraform"
  }
}