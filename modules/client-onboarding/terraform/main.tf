# ==========================================
# FinOps Audit Engine — Client-Side Module
# Source: github.com/romanbovda/cloud-finops-enterprise-baseline//modules/client-onboarding/terraform
# DO NOT EDIT — managed by FinOps Audit Engine
# ==========================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# ==========================================
# 1. Variables
# ==========================================

variable "cur_bucket_name" {
  description = "Name of the existing S3 bucket containing AWS CUR (Parquet format)"
  type        = string
}

variable "cur_glue_database_name" {
  description = "Name of the existing Glue Database where CUR table is defined"
  type        = string
}

variable "auditor_aws_account_id" {
  description = "The AWS Account ID of the FinOps consultancy (your account)"
  type        = string
}

variable "external_id" {
  description = "Unique string provided by the auditor to prevent Confused Deputy attack"
  type        = string
  sensitive   = true
}

# ==========================================
# 2. Athena Query Results Infrastructure
# ==========================================

resource "aws_s3_bucket" "athena_results" {
  # checkov:skip=CKV2_AWS_62: Event notifications not required for temporary Athena results bucket
  # checkov:skip=CKV_AWS_21: Versioning not required for temporary Athena results bucket
  # checkov:skip=CKV_AWS_144: Cross-region replication not required for temporary Athena results bucket
  # checkov:skip=CKV_AWS_145: SSE-KMS not required, default SSE-S3 is sufficient for temporary results
  # checkov:skip=CKV_AWS_18: Access logging not required for temporary Athena results bucket
  bucket        = "finops-audit-results-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket                  = aws_s3_bucket.athena_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results_cleanup" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "delete-after-3-days"
    status = "Enabled"
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }

    expiration {
      days = 3
    }
  }
}

resource "aws_athena_workgroup" "finops_audit" {
  name          = "finops-audit-wg"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true # Critical: Forces agent to use this specific bucket
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

# ==========================================
# 3. Least Privilege IAM Role & Policy
# ==========================================

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.auditor_aws_account_id}:root"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role" "finops_auditor" {
  name               = "FinOpsAuditCrossAccountRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "least_privilege" {
  # Access STRICTLY limited to the Athena Results Bucket (Read/Write)
  statement {
    sid       = "AthenaResultsBucketAccess"
    effect    = "Allow"
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.athena_results.arn]
  }

  statement {
    sid       = "AthenaResultsObjectAccess"
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:AbortMultipartUpload"
    ]
    resources = ["${aws_s3_bucket.athena_results.arn}/*"]
  }

  # Access STRICTLY limited to READ-ONLY on the client's existing CUR Bucket
  statement {
    sid       = "CURBucketReadAccess"
    effect    = "Allow"
    actions   = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${var.cur_bucket_name}"]
  }

  statement {
    sid       = "CURObjectReadAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.cur_bucket_name}/*"]
  }

  # Query execution STRICTLY limited to the isolated Workgroup
  statement {
    sid       = "AthenaWorkgroupAccess"
    effect    = "Allow"
    actions   = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:StopQueryExecution"
    ]
    resources = [aws_athena_workgroup.finops_audit.arn]
  }

  # Access STRICTLY limited to the CUR schema in the Glue Catalog
  statement {
    sid       = "GlueCatalogReadAccess"
    effect    = "Allow"
    actions   = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartitions"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/${var.cur_glue_database_name}",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.cur_glue_database_name}/*"
    ]
  }
}

resource "aws_iam_policy" "finops_auditor" {
  name        = "FinOpsAuditLeastPrivilegePolicy"
  description = "Strictly scoped access for automated FinOps auditing"
  policy      = data.aws_iam_policy_document.least_privilege.json
}

resource "aws_iam_role_policy_attachment" "finops_auditor_attach" {
  role       = aws_iam_role.finops_auditor.name
  policy_arn = aws_iam_policy.finops_auditor.arn
}

# ==========================================
# 4. Outputs (To give back to the Auditor)
# ==========================================

output "finops_role_arn" {
  description = "Provide this ARN to your FinOps consultant"
  value       = aws_iam_role.finops_auditor.arn
}
