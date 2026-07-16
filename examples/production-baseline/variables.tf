variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "The target AWS Account ID"
  type        = string
}

variable "org_root_id" {
  description = "The target AWS Organizations Root ID"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, stage, prod)"
  type        = string
  default     = "prod"
}

variable "monthly_budget_limit" {
  description = "The total monthly budget limit in USD"
  type        = number
  default     = 5000
}

variable "notification_emails" {
  description = "List of email addresses to receive budget and anomaly alerts"
  type        = list(string)
  default     = ["finops-alerts@example.com"]
}
