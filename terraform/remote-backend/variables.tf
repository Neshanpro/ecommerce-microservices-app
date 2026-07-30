
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "terraform_state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.terraform_state_bucket_name))
    error_message = "S3 bucket name must be valid (lowercase, hyphens, 3-63 chars)."
  }
}

variable "terraform_lock_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "ecommerce-terraform-lock"
}
