data "nutanix_karbon_clusters" "existing" {
  count = var.enable_data_lookups ? 1 : 0
}

data "nutanix_karbon_private_registries" "existing" {
  count = var.enable_data_lookups ? 1 : 0
}
