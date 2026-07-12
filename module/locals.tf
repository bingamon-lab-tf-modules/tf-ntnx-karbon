locals {
  # Existing Karbon clusters from data lookup
  existing_clusters = var.enable_data_lookups ? try(data.nutanix_karbon_clusters.existing[0].clusters, []) : []

  # Cluster name to ID mapping
  cluster_id_by_name = {
    for cluster in local.existing_clusters : cluster.name => cluster.uuid
  }

  # Existing private registries from data lookup
  existing_registries = var.enable_data_lookups ? try(data.nutanix_karbon_private_registries.existing[0].private_registries, []) : []

  # Registry name to endpoint mapping
  registry_endpoint_by_name = {
    for registry in local.existing_registries : registry.name => registry.endpoint
  }
}
