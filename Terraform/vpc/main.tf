resource "random_id" "suffix" {
  byte_length = 4
}
# -------------------
# VPC
# -------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}"
  })
}

# -------------------
# Internet Gateway
# -------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# -------------------
# Public Subnet
# -------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet"
  })
}

# -------------------
# Route Table
# -------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt"
  })
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------
# Security Group
# -------------------
resource "aws_security_group" "web" {
  vpc_id = aws_vpc.main.id

  name = "${local.name_prefix}-sg"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# -------------------
# EC2 Instance
# -------------------
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}

# -------------------
# AMI Lookup
# -------------------
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# resource "aws_iam_role" "lambda_role" {
#   #name = "${local.lambda_name}-role"
#   name = "${local.lambda_name}-role-${local.unique_suffix}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })

#   tags = local.common_tags
# }

# resource "aws_iam_policy" "lambda_policy" {
#   #name = "${local.lambda_name}-policy"
#   name = "${local.lambda_name}-policy-${local.unique_suffix}"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       # Logs
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "*"
#       },
#       # Example EC2 Snapshot permissions
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:DescribeSnapshots",
#           "ec2:DeleteSnapshot"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_attach" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

# resource "aws_lambda_function" "cpennymac" {
#   function_name = local.lambda_name
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.12"

#   filename         = "${path.module}/lambda/lambda_function.zip"
#   source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")

#   timeout = 60

#   tags = local.common_tags
# }
# resource "aws_cloudwatch_event_rule" "lambda_schedule" {
#   #name                = "${local.lambda_name}-schedule"
#   name = "${local.lambda_name}-schedule-${local.unique_suffix}"
#   schedule_expression = var.lambda_schedule

#   tags = local.common_tags
# }
# resource "aws_cloudwatch_event_target" "lambda_target" {
#   rule      = aws_cloudwatch_event_rule.lambda_schedule.name
#   target_id = "lambda"
#   arn       = aws_lambda_function.cpennymac.arn
# }
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpennymac.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = local.az

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = local.common_tags
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_iam_role" "cpennymac_role" {
  #name = "${local.cpennymac_lambda_name}-role"
  name = "${local.cpennymac_lambda_name}-role-${local.unique_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role" "pennymac_role" {
  #name = "${local.pennymac_lambda_name}-role"
  name = "${local.pennymac_lambda_name}-role-${local.unique_suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_policy" "cpennymac_policy" {
  #name = "${local.cpennymac_lambda_name}-policy"
  name = "${local.cpennymac_lambda_name}-policy-${local.unique_suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSnapshots",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}
# resource "aws_iam_policy" "pennymac_policy" {
#   #name = "${local.pennymac_lambda_name}-policy"
#   name = "${local.pennymac_lambda_name}-policy-${local.unique_suffix}"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:DescribeSnapshots"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:*"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }
resource "aws_iam_role_policy_attachment" "cpennymac_attach" {
  role       = aws_iam_role.cpennymac_role.name
  policy_arn = aws_iam_policy.cpennymac_policy.arn

  depends_on = [aws_iam_policy.cpennymac_policy]
}

resource "aws_iam_role_policy_attachment" "pennymac_attach" {
  role       = aws_iam_role.pennymac_role.name
  policy_arn = aws_iam_policy.pennymac_policy.arn

  depends_on = [aws_iam_policy.pennymac_policy]
}
resource "aws_lambda_function" "cpennymac" {
  #function_name = local.cpennymac_lambda_name
  function_name = "${local.cpennymac_lambda_name}-${local.unique_suffix}"
  role          = aws_iam_role.cpennymac_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/lambda/clean/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/cleanup/lambda_function.zip")

  timeout = 60
}
# resource "aws_lambda_function" "pennymac" {
#   function_name = local.pennymac_lambda_name
#   role          = aws_iam_role.pennymac_role.arn
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.12"

#   filename         = "${path.module}/lambda/reporting/lambda_function.zip"
#   source_code_hash = filebase64sha256("${path.module}/lambda/reporting/lambda_function.zip")

#   timeout = 60
# }
resource "aws_cloudwatch_event_rule" "cpennymac_schedule" {
  #name                = "${local.cpennymac_lambda_name}-schedule"
  name = "${local.cpennymac_lambda_name}-schedule-${local.unique_suffix}"
  schedule_expression = var.cpennymac_schedule

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_event_rule" "pennymac_schedule" {
  #name                = "${local.pennymac_lambda_name}-schedule"
  name = "${local.pennymac_lambda_name}-schedule-${local.unique_suffix}"
  schedule_expression = var.pennymac_schedule

  lifecycle {
  create_before_destroy = true
}
}
resource "aws_cloudwatch_event_target" "cpennymac_target" {
  rule = aws_cloudwatch_event_rule.cpennymac_schedule.name
  arn  = aws_lambda_function.cpennymac.arn
}

resource "aws_cloudwatch_event_target" "pennymac_target" {
  rule = aws_cloudwatch_event_rule.pennymac_schedule.name
  arn  = aws_lambda_function.pennymac.arn
}
resource "aws_lambda_permission" "cpennymac_allow" {
  statement_id  = "Allowcpennymac"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpennymac.function_name
  #function_name = "${local.lambda_name}-${local.unique_suffix}"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cpennymac_schedule.arn
}

resource "aws_lambda_permission" "pennymac_allow" {
  statement_id  = "Allowpennymac"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pennymac.function_name
  #function_name = "${local.lambda_name}-${local.unique_suffix}"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pennymac_schedule.arn
}
resource "aws_sns_topic" "pennymac_topic" {
  name = local.sns_topic_name
}
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.pennymac_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
resource "aws_iam_policy" "pennymac_policy" {
  #name = "${local.pennymac_lambda_name}-policy"
  name = "${local.pennymac_lambda_name}-policy-${local.unique_suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.pennymac_topic.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "pennymac" {
  #function_name = local.pennymac_lambda_name
  function_name = "${local.pennymac_lambda_name}-${local.unique_suffix}"
  role          = aws_iam_role.pennymac_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/lambda/reporting/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/reporting/lambda_function.zip")

  timeout = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.pennymac_topic.arn
    }
  }
}
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  #name                = "${local.lambda_name}-schedule"
  name = "${local.lambda_name}-schedule-${local.unique_suffix}"
  schedule_expression = var.lambda_schedule

  lifecycle {
    create_before_destroy = true
  }
}