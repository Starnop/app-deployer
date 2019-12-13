output "instances" {
  value = {
    for identifier, instance in module.app-deployer.this_instanceList : identifier => instance
  }
}