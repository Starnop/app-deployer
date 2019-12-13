output "this_instanceList" {
  value = alicloud_instance.instances
}

output "this_availability_zone" {
  value = local.zone_id
}
