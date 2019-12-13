provider "alicloud" {
  version                 = ">=1.60.0"
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "Starnop/cluster-module"
}

data "alicloud_zones" "zones_ds" {
  available_resource_creation = "Instance"
}

data "alicloud_images" "images" {
  for_each = local.instance_values

  owners      = each.value.image_owners == null ? "system" : each.value.image_owners
  name_regex  = each.value.image_name_regex == null ? "^centos_7_06" : each.value.image_name_regex
  most_recent = "true"
}

data "alicloud_instance_types" "ecs_type" {
  for_each = local.instance_values

  cpu_core_count = each.value.cpu
  memory_size    = each.value.memory
}

resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
}

resource "alicloud_security_group_rule" "allow_ingress_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# Create machines which the quantity equals (theNumberOfIdentifier * eachSize).
resource "alicloud_instance" "instances" {
  for_each = local.instances

  availability_zone = local.zone_id
  image_id          = each.value.image_id == null ? data.alicloud_images.images[each.value.identifier].ids[0] : each.value.image_id
  instance_type     = each.value.instance_type == null ? data.alicloud_instance_types.ecs_type[each.value.identifier].ids[0] : each.value.instance_type
  instance_name     = format("ecs-%s-%s", "${var.owner}", "${each.key}")
  host_name         = each.value.hostnamePrefix == null ? "" : format("%s%s", each.value.hostnamePrefix, split("_", each.key)[1])
  password          = each.value.ecs_password
  description       = format("OWNER: %s\n%s", "${var.owner}", each.value.description)
  user_data         = each.value.user_data == null ? null : each.value.user_data

  system_disk_category = "cloud_efficiency"
  system_disk_size     = each.value.system_disk_size
  dynamic "data_disks" {
    for_each = each.value.data_disks == null ? [] : each.value.data_disks

    content {
      name                 = lookup(data_disks.value, "name", null)
      size                 = lookup(data_disks.value, "size", null)
      category             = lookup(data_disks.value, "category", null)
      encrypted            = lookup(data_disks.value, "encrypted", null)
      snapshot_id          = lookup(data_disks.value, "snapshot_id", null)
      delete_with_instance = lookup(data_disks.value, "delete_with_instance", null)
      description          = lookup(data_disks.value, "description", null)
    }
  }

  private_ip                 = each.value.private_ip == null ? "" : length(each.value.private_ip) > 0 ? each.value.private_ip[split(each.key, "_")[1]] : ""
  security_groups            = each.value.security_groups == null ? [alicloud_security_group.default.id] : each.value.security_groups
  vswitch_id                 = each.value.vswitch_id
  internet_max_bandwidth_out = each.value.max_bandwidth_out == null ? 0 : each.value.max_bandwidth_out
}

# Render all template files to dir ${path.root}/.renderd_files.
resource "local_file" "file_render" {
  for_each = local.instance_temp_files

  content  = templatefile("${path.root}/${each.value}", { Instances = alicloud_instance.instances })
  filename = "${path.root}/.renderd_files/${each.value}"
}

# Put files with the same identifier in the same directory.
resource "null_resource" "file_organization" {
  for_each = local.instance_values

  # Copy all static_files to ${path.root}/.identifier.
  provisioner "local-exec" {
    command     = "sh shell/organize_files.sh ${each.key} ${abspath(path.root)} . ${each.value.static_files == null ? "" : join(";", each.value.static_files)}"
    working_dir = path.module
  }

  # Copy all temp_files to ${path.root}/.identifier.
  provisioner "local-exec" {
    command     = "sh shell/organize_files.sh ${each.key} ${abspath(path.root)} .renderd_files ${each.value.temp_files == null ? "" : join(";", each.value.temp_files)}"
    working_dir = path.module
  }

  triggers = {
    build_time = timestamp()
  }

  depends_on = [
    local_file.file_render,
  ]
}

# Transfer the files to the corresponding identifier machines via ssh.
// TODO: No need to establish an SSH link when no files are defined.
resource "null_resource" "file_trans" {
  for_each = alicloud_instance.instances

  connection {
    type     = "ssh"
    user     = "root"
    password = each.value.password
    host     = each.value.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "test -d /tmp/${var.app_name} || mkdir -p /tmp/${var.app_name}",
    ]
  }

  provisioner "file" {
    source      = "${path.root}/.${split("_", each.key)[0]}_files/"
    destination = "/tmp/${var.app_name}"
  }

  depends_on = [
    null_resource.file_organization,
  ]
}

# Start running the entrypoint command on each machine when all environments are ready.
// TODO: No need to establish an SSH link when the entrypoint command is not defined.
resource "null_resource" "run-entrypoint" {
  for_each = alicloud_instance.instances

  connection {
    type     = "ssh"
    user     = "root"
    password = each.value.password
    host     = each.value.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "${local.instances[each.key].entrypoint}"
    ]
  }

  depends_on = [
    null_resource.file_trans,
  ]
}


