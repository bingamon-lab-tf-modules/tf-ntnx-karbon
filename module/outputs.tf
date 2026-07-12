output "clusters" {
  description = "Karbon cluster details"
  value = {
    for k, v in nutanix_karbon_cluster.cluster : k => {
      name               = v.name
      version            = v.version
      status             = v.status
      kubeconfig         = v.kubeconfig
      worker_node_pool   = v.worker_node_pool
      etcd_node_pool     = v.etcd_node_pool
      master_node_pool   = v.master_node_pool
      storage_class_name = v.storage_class_config[0].name
      cni_type           = v.cni_config[0].calico_config != null ? "calico" : "flannel"
      pod_ipv4_cidr      = v.cni_config[0].pod_ipv4_cidr
      service_ipv4_cidr  = v.cni_config[0].service_ipv4_cidr
    }
  }
  sensitive = true
}

output "cluster_ids" {
  description = "Map of cluster names to IDs"
  value = {
    for k, v in nutanix_karbon_cluster.cluster : k => v.id
  }
}

output "cluster_kubeconfigs" {
  description = "Map of cluster keys to their kubeconfig"
  value = {
    for k, v in nutanix_karbon_cluster.cluster : k => v.kubeconfig
  }
  sensitive = true
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
    for k, v in nutanix_karbon_private_registry.registry : k => v.uuid
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
  value = {
    total_clusters      = length(nutanix_karbon_cluster.cluster)
    total_registries    = length(nutanix_karbon_private_registry.registry)
    clusters_by_version = { for v in distinct([for c in nutanix_karbon_cluster.cluster : c.version]) : v => length([for c in nutanix_karbon_cluster.cluster : c if c.version == v]) }
    clusters_by_cni = {
      calico  = length([for c in nutanix_karbon_cluster.cluster : c if c.cni_config[0].calico_config != null])
      flannel = length([for c in nutanix_karbon_cluster.cluster : c if c.cni_config[0].calico_config == null])
    }
    total_worker_nodes = sum([for c in nutanix_karbon_cluster.cluster : c.worker_node_pool[0].num_instances])
    total_master_nodes = sum([for c in nutanix_karbon_cluster.cluster : c.master_node_pool[0].num_instances])
    total_etcd_nodes   = sum([for c in nutanix_karbon_cluster.cluster : c.etcd_node_pool[0].num_instances])
  }
}
