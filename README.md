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


This solution implements an automated EC2 snapshot lifecycle management system using AWS serverless services and infrastructure-as-code principles.

It is designed to:

Automatically identify and delete outdated snapshots
Generate periodic snapshot reports
Notify stakeholders via email
Operate within a secure, private network architecture


This solution implements an automated EC2 snapshot lifecycle management system using AWS serverless services and infrastructure-as-code principles.

It is designed to:

 Automatically identify and delete outdated snapshots
 Generate periodic snapshot reports
 Notify stakeholders via email
 Operate within a secure, private network architecture


## Infrastructure as Code (IaC) Approach

## Tool Selected: Terraform


Terraform was selected as the IaC tool for the following reasons:

Declarative Infrastructure Management
  Enables consistent and repeatable provisioning of AWS resources.

Idempotent Execution
  Ensures safe re-runs without unintended duplication.

Multi-Service Orchestration
  Allows coordinated deployment of networking, compute, IAM, and messaging components.



## Infrastructure Deployment Process

### Execution Workflow

Infrastructure provisioning is executed through Terraform using standard lifecycle commands:

 Initialize provider dependencies
 Validate execution plan
 Apply infrastructure configuration

This process results in the automated creation of:

 Virtual Private Cloud (VPC)
 Public and Private Subnets
 Internet Gateway and NAT Gateway
 IAM Roles and Policies
 Lambda Functions (Cleanup and Reporting)
 EventBridge Scheduled Rules
 SNS Topic and Email Subscription


### Key Design Considerations

Private Subnet Execution
  All compute resources (Lambda) operate within a private subnet.

Controlled Internet Access
  Outbound access is routed through a NAT Gateway.

Deterministic Resource Naming
  Ensures predictable deployments across environments.

Separation of Concerns
  Cleanup and reporting functions are implemented as independent services.


## Lambda Function Deployment

Lambda functions are deployed as packaged artifacts and managed through Terraform.

## Deployment Model

Source code is packaged into deployable artifacts
Terraform references these artifacts during deployment
Updates are triggered automatically when code changes are detected

### Functional Responsibilities

Cleanup Function

 Identifies snapshots older than the defined retention period
 Deletes eligible snapshots
 Logs all actions

Reporting Function

 Retrieves snapshot inventory
 Generates structured report
 Publishes report via SNS


##  VPC Configuration for Lambda

Ensure Lambda functions operate within a **secure, isolated network environment** while maintaining required outbound connectivity.

### Configuration Components

Private Subnet

  Hosts Lambda execution environment
  No direct inbound internet access

Security Groups

  Control outbound traffic from Lambda
  Restrict unnecessary network exposure

NAT Gateway

   Enables outbound communication (e.g., AWS APIs, SNS)

### Outcome

 Enhanced security posture
 Compliance with enterprise network standards
 Controlled and auditable connectivity

## Notification Mechanism (SNS Integration)

The reporting workflow integrates with **Amazon SNS** to deliver email notifications.

### Process Flow

Reporting Lambda generates snapshot report
Report is published to SNS topic
SNS distributes notification to subscribed email recipients

### Operational Note

Email subscriptions require **manual confirmation** before activation.


The implementation is based on the following:

 AWS Region is predefined (e.g., `us-east-1`)
 Snapshot ownership is limited to the executing account
 Lambda runtime environment is Python-based
 Network configuration includes NAT Gateway for outbound access
 Required IAM permissions are available for resource provisioning
 Email endpoint for notifications is valid and monitored


### Logging – Amazon CloudWatch Logs

 All Lambda executions generate structured logs
 Logs capture:

   Snapshot processing actions
   Deletion events
   Errors and exceptions


## Configure CloudWatch Alarms for:

 Lambda execution failures
 Elevated error rates
 Integrate alerts with SNS or incident management systems


### Execution Sequence

1. EventBridge triggers Lambda functions on a defined schedule
2. Cleanup Lambda evaluates and deletes outdated snapshots
3. Reporting Lambda compiles snapshot inventory
4. SNS distributes report via email
5. Logs and metrics are recorded for monitoring


# Security Considerations

Least Privilege IAM Policies
  Lambda functions are granted only required permissions

Network Isolation
  Execution occurs within private subnet

No Inbound Exposure
  No public access to compute resources

Controlled Messaging Access
  SNS permissions restricted to publish-only



## Architecture Design Summary

The architecture follows a serverless, event-driven model:

EventBridge orchestrates scheduled execution
Lambda performs processing and automation
SNS enables notification delivery
VPC enforces network isolation and security


This implementation demonstrates a production-aligned, secure, and automated AWS solution for managing EC2 snapshot lifecycles. By leveraging Terraform and AWS serverless services, the solution achieves **operational efficiency, governance, and scalability** while adhering to enterprise best practices.
