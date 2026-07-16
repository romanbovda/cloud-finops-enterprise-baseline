variable "notification_emails" {
  description = "List of email addresses to receive budget and anomaly alerts"
  type        = list(string)

  validation {
    condition     = length(var.notification_emails) > 0
    error_message = "At least one notification email must be provided."
  }
}

variable "monthly_budget_limit" {
  description = "The total monthly budget limit in USD"
  type        = number
  default     = 1000

  validation {
    condition     = var.monthly_budget_limit > 0
    error_message = "The monthly budget limit must be greater than 0."
  }
}

variable "account_id" {
  description = "The AWS Account ID"
  type        = string
  
  validation {
    condition     = can(regex("^\\d{12}$", var.account_id)) || var.account_id == "<AWS_ACCOUNT_ID>"
    error_message = "The account_id must be exactly 12 digits."
  }
}

variable "environment" {
  description = "The deployment environment (dev, stage, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "tags" {
  description = "Tags to apply to FinOps resources"
  type        = map(string)
  default = {
    ManagedBy   = "terraform"
    Department  = "finops"
    Company     = "your-company-name"
  }
}
