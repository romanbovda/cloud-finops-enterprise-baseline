variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "The target AWS Account ID"
  type        = string
}

variable "org_root_id" {
  description = "The target AWS Organizations Root ID"
  type        = string
}
