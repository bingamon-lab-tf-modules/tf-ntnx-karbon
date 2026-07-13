data "nutanix_karbon_clusters" "existing" {
  count = var.enable_data_lookups ? 1 : 0
}

data "nutanix_karbon_private_registries" "existing" {
  count = var.enable_data_lookups ? 1 : 0
}

# Kubeconfig material for each created cluster. Provider 2.4.2's
# nutanix_karbon_cluster resource exposes NO kubeconfig attribute, so the
# kubeconfig is fetched here (one lookup per created cluster) and assembled in
# locals.tf.
data "nutanix_karbon_cluster_kubeconfig" "cluster" {
  for_each = nutanix_karbon_cluster.cluster

  karbon_cluster_name = each.value.name
}
