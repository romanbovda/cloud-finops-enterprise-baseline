# FinOps Audit Engine: Client Onboarding

Welcome to the FinOps & SRE Consulting Services onboarding process. To maintain strict data sovereignty and comply with our **Zero Data Extraction** policy, our proprietary audit engine executes performance and cost queries directly within your AWS environment using Amazon Athena.

To enable this capability, please deploy the provided Terraform module in your AWS environment. This module references our secure, open-source architecture directly from GitHub — **no files to manually copy, and no external scripts to execute**.

> [!NOTE]
> **What does this deploy?** 
> This module provisions a secure Athena Workgroup, a temporary S3 bucket for query results (automatically purged after 3 days via lifecycle rules), and a Least Privilege Cross-Account IAM Role protected by a cryptographically unique `ExternalId`. The full source code is publicly auditable in our repository under `terraform/main.tf`.

---

## Prerequisites

Before proceeding with the deployment, please ensure the following prerequisites are met within your AWS environment:

1. **AWS Cost and Usage Reports (CUR)** are enabled in the AWS Billing Console.
2. The CUR is actively configured to export data in **Apache Parquet** format.
3. **CUR Data Integration** is enabled for **Amazon Athena** (this automatically provisions the AWS Glue Data Catalog database, typically named `athenacurcfn_<report-name>`).

> [!TIP]
> Unlike some cloud providers that require explicit API enablement, Amazon S3, AWS IAM, and Amazon Athena APIs are enabled by default for all AWS accounts. No manual API activation is required.

---

## Deployment Instructions

### Step 1: Configure the Deployment

In your preferred Terraform workspace, create a configuration file (e.g., `finops_onboarding.tf`) using the following template:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "YOUR_CUR_REGION"  # e.g., "eu-west-1"
}

module "finops_audit_integration" {
  source = "github.com/romanbovda/cloud-finops-enterprise-baseline//modules/client-onboarding/terraform?ref=main"

  cur_bucket_name        = "YOUR_CUR_S3_BUCKET_NAME"
  cur_glue_database_name = "athenacurcfn_cur"
  
  # The following values will be securely provided by your consulting engagement manager:
  auditor_aws_account_id = "AUDITOR_ACCOUNT_ID"   
  external_id            = "EXTERNAL_ID"           
}

output "finops_role_arn" {
  value = module.finops_audit_integration.finops_role_arn
}
```

### Step 2: Execute Deployment

Authenticate with your AWS environment using an identity with sufficient permissions (see Required Permissions below), and execute the standard Terraform workflow:

```bash
terraform init   # Initializes the module from the source repository
terraform plan   # Reviews the intended infrastructure state (S3, Athena Workgroup, IAM Role)
terraform apply  # Provisions the resources
```

### Step 3: Securely Share Outputs

Upon successful deployment, Terraform will output a value named `finops_role_arn`. Please share this securely with your dedicated consulting engagement manager. This Role ARN is the only requirement from your side to initialize the audit engine.

---

## Required Deployment Permissions

The engineering team or CI/CD pipeline executing the deployment must be authorized to create the specific resources. If you are not utilizing `AdministratorAccess`, please ensure the deployment role includes at least the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ManageIAMRoleAndPolicy",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole", "iam:GetRole", "iam:DeleteRole",
                "iam:UpdateAssumeRolePolicy", "iam:CreatePolicy",
                "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions",
                "iam:DeletePolicy", "iam:AttachRolePolicy", "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies"
            ],
            "Resource": [
                "arn:aws:iam::*:role/FinOpsAuditCrossAccountRole",
                "arn:aws:iam::*:policy/FinOpsAuditLeastPrivilegePolicy"
            ]
        },
        {
            "Sid": "ManageS3Buckets",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket", "s3:DeleteBucket", "s3:ListBucket",
                "s3:GetBucketLocation", "s3:PutBucketPublicAccessBlock",
                "s3:GetBucketPublicAccessBlock", "s3:PutLifecycleConfiguration",
                "s3:GetLifecycleConfiguration", "s3:PutEncryptionConfiguration",
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "arn:aws:s3:::finops-audit-results-*"
        },
        {
            "Sid": "ManageAthenaWorkgroup",
            "Effect": "Allow",
            "Action": [
                "athena:CreateWorkGroup", "athena:GetWorkGroup",
                "athena:DeleteWorkGroup", "athena:UpdateWorkGroup", "athena:TagResource"
            ],
            "Resource": "arn:aws:athena:*:*:workgroup/finops-audit-wg"
        }
    ]
}
```

---

## Security Overview

We strongly encourage your Security Operations and CISO teams to review the underlying module at [`terraform/main.tf`](./terraform/main.tf). Key architectural security controls include:

- **Strict IAM Scoping:** Permissions are explicitly scoped to the designated Athena Workgroup ARN and the `finops-audit-results-*` S3 bucket pattern. We avoid wildcard resource grants.
- **Enforced Workgroup Boundaries:** The Athena Workgroup enforces that query results can **only** be written to the local S3 bucket, physically preventing our engine from redirecting output externally.
- **Read-Only Data Access:** The IAM role is granted restricted `s3:GetObject` access to your CUR bucket. It has zero capability to write, list, or delete your underlying billing data.
- **ExternalId Protection:** The Trust Policy incorporates an `ExternalId` condition, neutralizing [Confused Deputy attacks](https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html).
- **Automated Data Lifecycle:** All transient Athena query results are automatically purged after 3 days via an S3 lifecycle rule.
- **Micro-Payload Exfiltration:** The audit engine is architected to read only the **aggregated output** of SQL queries (typically kilobytes of analytical metrics), ensuring your raw CUR files never leave your environment.

For a complete visual representation of this secure boundary, please refer to our [`architecture_overview.md`](./architecture_overview.md).
