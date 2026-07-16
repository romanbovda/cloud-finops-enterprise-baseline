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

# -----------------------------------------------------------------------------
# Example Resource for Cost Estimation (Infracost)
# -----------------------------------------------------------------------------
resource "aws_instance" "example_workload" {
  ami                  = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type        = "t3.medium"
  ebs_optimized        = true
  iam_instance_profile = "finops-demo-profile"
  monitoring           = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "finops-demo-workload"
    Owner       = "finops-team"
    Project     = "enterprise-baseline"
    Environment = "production"
    CostCenter  = "CC-12345"
  }
}
