variable "region" {
  description = "The region ID used to launch this module resources. If not set, it will be sourced from followed by ALICLOUD_REGION environment variable and profile."
  default     = ""
}