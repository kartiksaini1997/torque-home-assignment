variable "region" {
  type        = string
  description = "AWS region"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for bucket name (random suffix appended)"
}

variable "enable_versioning" {
  type        = bool
  description = "Enable S3 versioning"
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Allow deleting a non-empty bucket (demo-friendly)"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
