variable "notification_emails" {
  description = "List of email addresses to receive budget and anomaly alerts"
  type        = list(string)
  default     = ["finops-alerts@example.com"]
}

variable "monthly_budget_limit" {
  description = "The total monthly budget limit in USD"
  type        = string
  default     = "1000.0"
}

variable "account_id" {
  description = "The AWS Account ID"
  type        = string
  default     = "<AWS_ACCOUNT_ID>"
}

variable "tags" {
  description = "Tags to apply to FinOps resources"
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
    Department  = "finops"
    Company     = "your-company-name"
  }
}
