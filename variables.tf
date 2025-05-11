variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "default_tags" {
  description = "Default tags to be applied to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "poc"
  }
}