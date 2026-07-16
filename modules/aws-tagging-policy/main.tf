# -----------------------------------------------------------------------------
# AWS Organizations Service Control Policy (SCP) for Tagging Enforcement
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "require_tags" {
  statement {
    sid       = "RequireMandatoryTagsOnCreation"
    effect    = "Deny"
    actions   = [
      "ec2:RunInstances",
      "ec2:CreateVolume",
      "rds:CreateDBInstance",
      "rds:CreateDBCluster"
    ]
    resources = ["*"]

    # Block creation if ANY of the mandatory tags are missing
    dynamic "condition" {
      for_each = var.mandatory_tags
      content {
        test     = "Null"
        variable = "aws:RequestTag/${condition.value}"
        values   = ["true"]
      }
    }
  }
}

resource "aws_organizations_policy" "tagging_policy" {
  name        = "EnforceMandatoryTagsSCP"
  description = "Requires specific tags on expensive resources upon creation."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.require_tags.json
}

resource "aws_organizations_policy_attachment" "tagging_attachment" {
  policy_id = aws_organizations_policy.tagging_policy.id
  target_id = var.target_id
}
