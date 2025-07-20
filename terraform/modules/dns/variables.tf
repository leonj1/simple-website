variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "root_domain" {
  description = "Root domain for Route53 zone lookup"
  type        = string
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = false
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}