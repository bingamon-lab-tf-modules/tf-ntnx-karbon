output "clusters" {
  description = "Karbon cluster details"
  value       = local.out_clusters
  sensitive   = true
}

output "cluster_ids" {
  description = "Map of cluster names to IDs"
  value = {
    for k, v in nutanix_karbon_cluster.cluster : k => v.id
  }
}

output "cluster_kubeconfigs" {
  description = "Map of cluster keys to their kubeconfig"
  value       = local.kubeconfig_by_cluster
  sensitive   = true
}

output "cluster_endpoints" {
  description = "Map of cluster keys to their Kubernetes API server endpoints"
  value = {
    for k, v in nutanix_karbon_cluster.cluster : k => v.kubeapi_server_ipv4_address
  }
}

output "registries" {
  description = "Private registry details"
  value = {
    for k, v in nutanix_karbon_private_registry.registry : k => {
      name     = v.name
      endpoint = v.endpoint
      url      = v.url
      port     = v.port
    }
  }
}

output "registry_ids" {
  description = "Map of registry names to UUIDs"
  value = {
    for k, v in nutanix_karbon_private_registry.registry : k => v.id
  }
}

output "existing_cluster_ids" {
  description = "Map of existing (data-lookup) Karbon cluster names to UUIDs. Populated only when enable_data_lookups is true."
  value       = local.cluster_id_by_name
}

output "existing_registry_endpoints" {
  description = "Map of existing (data-lookup) private registry names to endpoints. Populated only when enable_data_lookups is true."
  value       = local.registry_endpoint_by_name
}

output "karbon_summary" {
  description = "Summary of Karbon resources"
  value       = local.out_karbon_summary
}

# ---------------------------------------------------------------------------
# Aggregate output (spec §7.6 contract)
# ---------------------------------------------------------------------------
output "outputs" {
  description = "Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs)."
  sensitive   = true
  value = {
    clusters = local.out_clusters
    cluster_ids = {
      for k, v in nutanix_karbon_cluster.cluster : k => v.id
    }
    cluster_kubeconfigs = local.kubeconfig_by_cluster
    cluster_endpoints = {
      for k, v in nutanix_karbon_cluster.cluster : k => v.kubeapi_server_ipv4_address
    }
    registries = {
      for k, v in nutanix_karbon_private_registry.registry : k => {
        name     = v.name
        endpoint = v.endpoint
        url      = v.url
        port     = v.port
      }
    }
    registry_ids = {
      for k, v in nutanix_karbon_private_registry.registry : k => v.id
    }
    existing_cluster_ids        = local.cluster_id_by_name
    existing_registry_endpoints = local.registry_endpoint_by_name
    karbon_summary              = local.out_karbon_summary
  }
}
