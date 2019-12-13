locals {
  zone_id = var.availability_zone != "" ? var.availability_zone : data.alicloud_zones.zones_ds.zones.0.id
}

# The local variables parsed from input variables.
locals {
  # A map from identifier to instanceSetting.
  # 
  # Eg. master => &Setting{}
  instance_values = tomap({
    for setting in var.instance_settings : "${setting.identifier}" => setting
  })

  # A tuple whose value is identifier_index, and the index ranges from zero to size.
  # 
  # Eg. master_0
  instance_keys = flatten([
    for setting in var.instance_settings : [
      for index in range(setting.size) : "${setting.identifier}_${index}"
    ]
  ])

  # A map from identifier_index to instanceSetting.
  # 
  # Eg. master_0 => &Setting{}
  instances = {
    for key in local.instance_keys : "${key}" => local.instance_values[split("_", key)[0]]
  }

  # A tuple whose value is temp file path of all instances 
  # which facilitate render operations to render all template files uniformly.
  # 
  # Eg. temp_files/template.yml
  instance_temp_files = toset(flatten([
    for setting in var.instance_settings : setting.temp_files == null ? [] : setting.temp_files
  ]))
}

