variable "target_id" {
  description = "The root ID, Organizational Unit ID, or AWS Account ID to attach the policy to."
  type        = string
}

variable "mandatory_tags" {
  description = "List of tag keys that must be present on specified resources."
  type        = list(string)
  default     = ["Owner", "Project", "Environment"]
}
