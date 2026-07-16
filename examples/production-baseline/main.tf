provider "aws" {
  region = var.aws_region
}

module "aws_finops_baseline" {
  source = "../../modules/aws-finops-baseline"

  account_id           = var.aws_account_id
  environment          = var.environment
  monthly_budget_limit = var.monthly_budget_limit
  notification_emails  = var.notification_emails
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Department  = "finops"
    Company     = "your-company-name"
  }
}

module "aws_tagging_policy" {
  source = "../../modules/aws-tagging-policy"

  target_id      = var.org_root_id
  mandatory_tags = ["Owner", "Project", "Environment", "CostCenter"]
}
