variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_ip" {
  description = "IP allowed for SSH"
  type        = string
}
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "snapshot-cleanup"
}

variable "lambda_schedule" {
  description = "Schedule expression for Lambda"
  type        = string
  default     = "rate(1 day)"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}