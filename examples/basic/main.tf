module "app-deployer" {
  source = "../../"

  region            = var.region != "" ? var.region : null
  availability_zone = module.vpc.this_availability_zones[0]
  vpc_id            = module.vpc.this_vpc_id

  app_name = "example"
  instance_settings = [
    {
      identifier        = "master"
      description       = "master node"
      hostnamePrefix    = "master"
      ecs_password      = "Example123"
      image_id          = null
      image_owners      = null
      image_name_regex  = null
      instance_type     = null
      cpu               = 2
      memory            = 4
      system_disk_size  = 100
      data_disks        = null
      max_bandwidth_out = 100
      security_groups   = null
      vswitch_id        = module.vpc.this_vswitch_ids[0]
      private_ip        = null
      user_data         = null
      temp_files        = ["temp_files/master_template.file"]
      static_files      = ["static_files/master_static.file"]
      entrypoint        = "echo SUCCESS"
      size              = 2
    },
    {
      identifier        = "worker"
      description       = "worker node"
      hostnamePrefix    = "worker"
      ecs_password      = "Example123"
      image_id          = null
      image_owners      = null
      image_name_regex  = null
      instance_type     = null
      cpu               = 4
      memory            = 8
      system_disk_size  = 100
      data_disks        = null
      max_bandwidth_out = 100
      security_groups   = null
      vswitch_id        = module.vpc.this_vswitch_ids[0]
      private_ip        = null
      temp_files        = ["temp_files/worker_template.file"]
      static_files      = ["static_files/worker_static.file"]
      user_data         = null
      entrypoint        = "echo SUCCESS"
      size              = 3
    }
  ]
}

module "vpc" {
  source = "alibaba/vpc/alicloud"

  region       = var.region != "" ? var.region : null
  vpc_name     = "my_vpc"
  vswitch_name = "my_vswitch"

  vswitch_cidrs = [
    "172.16.1.0/24",
  ]
}
