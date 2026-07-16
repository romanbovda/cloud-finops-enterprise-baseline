output "budget_arn" {
  description = "The ARN of the AWS Budget"
  value       = aws_budgets_budget.cost_budget.arn
}

output "anomaly_monitor_arn" {
  description = "The ARN of the AWS Cost Anomaly Monitor"
  value       = aws_ce_anomaly_monitor.service_monitor.arn
}

output "anomaly_subscription_arn" {
  description = "The ARN of the AWS Cost Anomaly Subscription"
  value       = aws_ce_anomaly_subscription.realtime_subscription.arn
}
