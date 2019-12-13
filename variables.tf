variable "region" {
  description = "The region ID used to launch this module resources. If not set, it will be sourced from followed by ALICLOUD_REGION environment variable and profile."
  default     = ""
}

variable "profile" {
  description = "The profile name as set in the shared credentials file. If not set, it will be sourced from the ALICLOUD_PROFILE environment variable."
  default     = ""
}

variable "shared_credentials_file" {
  description = "This is the path to the shared credentials file. If this is not set and a profile is specified, $HOME/.aliyun/config.json will be used."
  default     = ""
}

variable "skip_region_validation" {
  description = "Skip static validation of region ID. Used by users of alternative AlibabaCloud-like APIs or users w/ access to regions that are not public (yet)."
  default     = false
}

variable "availability_zone" {
  description = "The available zone to launch this module resources. The value should be consistent with your VPC."
  default     = ""
}

variable "vpc_id" {
  description = "The vpc id. If this is not set and no default value will be used."
  default     = ""
}

variable "owner" {
  description = "The owner identifier who deploy the app."
  default     = "default"
}

variable "app_name" {
  description = "The name of app that you will deployed. And all files you defined in the instance_settings will be placed under /tmp/app_name."
  default     = "default"
}

// TODO: Optional arguments in object variable type definition.
// Refer: https://github.com/hashicorp/terraform/issues/19898
variable "instance_settings" {
  description = "The instance settings which contains the instance resoure definitions, the file path that need to be uploaded to the machine and the entrypoint that need to be run after the resources are ready."
  type = list(object({
    # system config
    identifier  = string
    description = string
    size        = number

    # instance config
    hostnamePrefix   = string
    ecs_password     = string
    image_id         = string
    image_owners     = string
    image_name_regex = string
    instance_type    = string
    cpu              = number
    memory           = number

    # disk config
    system_disk_size = number
    data_disks       = list(map(string))

    # network config
    max_bandwidth_out = number
    security_groups   = list(string)
    vswitch_id        = string
    private_ip        = list(string)

    # app data
    user_data    = string
    temp_files   = list(string)
    static_files = list(string)
    entrypoint   = string
  }))
}

