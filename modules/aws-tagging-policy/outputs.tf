output "policy_id" {
  description = "The ID of the Tagging SCP"
  value       = aws_organizations_policy.tagging_policy.id
}

output "policy_arn" {
  description = "The ARN of the Tagging SCP"
  value       = aws_organizations_policy.tagging_policy.arn
}
