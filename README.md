# Technical-Exercise-Pennymac
cd lambda/cleanup
zip lambda_function.zip lambda_function.py

cd ../reporting
zip lambda_function.zip lambda_function.py

# Deployment: Describe how you would package and deploy the Lambda function (e.g., using the AWS CLI, Serverless Framework, or Terraform).

The Lambda functions are packaged by zipping the Python source files into deployment artifacts. These artifacts are referenced in Terraform using the filename and source_code_hash arguments. Terraform is then used to deploy both the Lambda functions and associated AWS resources (IAM roles, SNS, EventBridge rules) using terraform init and terraform apply. For improved automation, the archive_file data source can be used to dynamically generate the zip files during deployment. Alternative deployment methods include the AWS CLI and the Serverless Framework, but Terraform is preferred as it enables full infrastructure-as-code and repeatable deployments.

Deployment Approach for Lambda Functions

1. Packaging the Lambda Function

For both functions (cleanup and reporting), the code must be packaged into a .zip file before deployment.

1. Project structure
lambda/
├── cleanup/
│   ├── lambda_function.py
│   └── lambda_function.zip
└── reporting/
    ├── lambda_function.py
    └── lambda_function.zip

 Packaging Steps (Manual)

Run the following:

cd lambda/cleanup
zip lambda_function.zip lambda_function.py

cd ../reporting
zip lambda_function.zip lambda_function.py

This creates deployment artifacts required by AWS Lambda.

2. Deployment Using Terraform (PRIMARY METHOD )

Terraform is used to:

Provision infrastructure (IAM, SNS, EventBridge)
Deploy Lambda functions
Configure triggers and permissions
Lambda Deployment in Terraform

Example: see code details

Deploy Command

terraform init
terraform plan
terraform apply

What Terraform Does

Uploads .zip to Lambda
Creates IAM roles & policies
Configures EventBridge schedule
Sets environment variables (SNS topic)
Links triggers automatically