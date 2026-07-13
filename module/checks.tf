check "clusters_have_valid_node_counts" {
  assert {
    condition = alltrue([
      for k, v in var.clusters :
      v.worker_node_pool.num_instances >= 1
    ])
    error_message = "Karbon clusters should have at least 1 worker node."
  }
}

check "clusters_have_etcd_odd_count" {
  assert {
    condition = alltrue([
      for k, v in var.clusters :
      v.etcd_node_pool.num_instances % 2 == 1
    ])
    error_message = "Karbon clusters should have an odd number of etcd nodes for quorum."
  }
}
