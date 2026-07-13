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

  # Assembled kubeconfig (YAML) per created cluster. The provider's
  # cluster_kubeconfig data source returns the access token, CA certificate and
  # API server URL separately; compose them into a standard kubeconfig document.
  kubeconfig_by_cluster = {
    for cluster_key, kubeconfig in data.nutanix_karbon_cluster_kubeconfig.cluster :
    cluster_key => yamlencode({
      apiVersion = "v1"
      kind       = "Config"
      clusters = [{
        name = kubeconfig.name
        cluster = {
          server                       = kubeconfig.cluster_url
          "certificate-authority-data" = kubeconfig.cluster_ca_certificate
        }
      }]
      users = [{
        name = kubeconfig.name
        user = {
          token = kubeconfig.access_token
        }
      }]
      contexts = [{
        name = kubeconfig.name
        context = {
          cluster = kubeconfig.name
          user    = kubeconfig.name
        }
      }]
      "current-context" = kubeconfig.name
    })
  }

  # ---------------------------------------------------------------------------
  # Factored output value expressions
  #
  # These larger output values are defined once here and referenced from both
  # their individual `output` block and the aggregate `output "outputs"` (spec
  # §7.6 contract). Terraform cannot reference one output from another, so this
  # local is the shared single source of truth. Behaviour is unchanged.
  # ---------------------------------------------------------------------------

  # Karbon cluster details (used by output "clusters"). Sensitive (kubeconfig).
  out_clusters = {
    for k, v in nutanix_karbon_cluster.cluster : k => {
      name               = v.name
      version            = v.version
      status             = v.status
      kubeconfig         = local.kubeconfig_by_cluster[k]
      worker_node_pool   = v.worker_node_pool
      etcd_node_pool     = v.etcd_node_pool
      master_node_pool   = v.master_node_pool
      storage_class_name = one(v.storage_class_config).name
      cni_type           = length(v.cni_config[0].calico_config) > 0 ? "calico" : "flannel"
      pod_ipv4_cidr      = v.cni_config[0].pod_ipv4_cidr
      service_ipv4_cidr  = v.cni_config[0].service_ipv4_cidr
    }
  }

  # Summary of Karbon resources (used by output "karbon_summary").
  out_karbon_summary = {
    total_clusters      = length(nutanix_karbon_cluster.cluster)
    total_registries    = length(nutanix_karbon_private_registry.registry)
    clusters_by_version = { for v in distinct([for c in nutanix_karbon_cluster.cluster : c.version]) : v => length([for c in nutanix_karbon_cluster.cluster : c if c.version == v]) }
    clusters_by_cni = {
      calico  = length([for c in nutanix_karbon_cluster.cluster : c if length(c.cni_config[0].calico_config) > 0])
      flannel = length([for c in nutanix_karbon_cluster.cluster : c if length(c.cni_config[0].calico_config) == 0])
    }
    total_worker_nodes = length(nutanix_karbon_cluster.cluster) == 0 ? 0 : sum([for c in nutanix_karbon_cluster.cluster : c.worker_node_pool[0].num_instances])
    total_master_nodes = length(nutanix_karbon_cluster.cluster) == 0 ? 0 : sum([for c in nutanix_karbon_cluster.cluster : c.master_node_pool[0].num_instances])
    total_etcd_nodes   = length(nutanix_karbon_cluster.cluster) == 0 ? 0 : sum([for c in nutanix_karbon_cluster.cluster : c.etcd_node_pool[0].num_instances])
  }
}
