# -----------------------------------------------------------------------------
# AWS Budgets: Overall Monthly Cost Budget
# -----------------------------------------------------------------------------
resource "aws_budgets_budget" "cost_budget" {
  name              = "monthly-budget-limit"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  # Alert at 80% of actual costs
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }

  # Alert at 100% of forecasted costs
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.notification_emails
  }
}

# -----------------------------------------------------------------------------
# AWS Cost Anomaly Detection
# -----------------------------------------------------------------------------
resource "aws_ce_anomaly_monitor" "service_monitor" {
  name              = "AWSServiceMonitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "realtime_subscription" {
  name             = "RealtimeAnomalySubscription"
  frequency        = "DAILY"
  monitor_arn_list = [aws_ce_anomaly_monitor.service_monitor.arn]

  subscriber {
    type    = "EMAIL"
    address = var.notification_emails[0]
  }

  threshold_expression {
    dimension {
      key            = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options  = ["GREATER_THAN_OR_EQUAL"]
      values         = ["10.0"] # Alert on anomalies > $10
    }
  }
}
