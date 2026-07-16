# Production FinOps Baseline Example

This example demonstrates how to deploy the enterprise FinOps baseline across your AWS Organization.

## What this deploys

1. **AWS Budgets**: A strict monthly budget limit with automated email alerts at 80%, 90%, and 100% utilization.
2. **Cost Anomaly Detection**: An ML-driven monitor that sends immediate alerts for unexpected AWS spending spikes.
3. **Tagging SCP**: A Service Control Policy applied at the Organizational root that denies the creation of expensive resources (EC2, RDS, EBS) unless mandatory tags (`Owner`, `Project`, `Environment`, `CostCenter`) are provided.

## Prerequisites

- Terraform `>= 1.5.0`
- AWS credentials with permissions to manage Budgets, Cost Explorer, and AWS Organizations.

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Update `terraform.tfvars` with your actual AWS Account ID and Organization Root ID.
3. Initialize and apply:
   ```bash
   terraform init
   terraform apply
   ```
