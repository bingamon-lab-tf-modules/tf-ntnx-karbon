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
}
