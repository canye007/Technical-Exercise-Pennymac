locals {
  lambda_name = "${var.environment}-${var.lambda_function_name}"
}

locals {
  az = "${var.aws_region}a"
}
locals {
  cpennymac_lambda_name  = "${var.environment}-snapshot-cleanup"
  pennymac_lambda_name   = "${var.environment}-snapshot-report"
}
locals {
  sns_topic_name = "${var.environment}-snapshot-pennymac-topic"
}
locals {
  unique_suffix = random_id.suffix.hex
}
locals {
  name_prefix   = "${var.environment}-vpc"

  common_tags = {
    Environment = var.environment
    Project     = "public-vpc"
    ManagedBy   = "Terraform"
  }
}