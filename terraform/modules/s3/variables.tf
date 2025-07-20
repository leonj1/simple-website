variable "create_bucket" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix/folder for website files"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "index_document" {
  description = "Index document for static website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for static website"
  type        = string
  default     = "error.html"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}