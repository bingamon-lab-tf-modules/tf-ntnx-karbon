resource "nutanix_karbon_cluster" "cluster" {
  for_each = var.clusters

  name    = each.value.name
  version = each.value.version

  storage_class_config {
    name           = each.value.storage_class_config.name
    reclaim_policy = each.value.storage_class_config.reclaim_policy
    volumes_config {
      file_system                = each.value.storage_class_config.volumes_config.file_system
      flash_mode                 = each.value.storage_class_config.volumes_config.flash_mode
      password                   = each.value.storage_class_config.volumes_config.password
      prism_element_cluster_uuid = each.value.storage_class_config.volumes_config.prism_element_cluster_uuid
      storage_container          = each.value.storage_class_config.volumes_config.storage_container
      username                   = each.value.storage_class_config.volumes_config.username
    }
  }

  cni_config {
    node_cidr_mask_size = each.value.cni_config.node_cidr_mask_size
    pod_ipv4_cidr       = each.value.cni_config.pod_ipv4_cidr
    service_ipv4_cidr   = each.value.cni_config.service_ipv4_cidr

    dynamic "flannel_config" {
      for_each = each.value.cni_config.calico_config == null ? [1] : []
      content {
        # Flannel is the default CNI, no additional configuration needed
      }
    }

    dynamic "calico_config" {
      for_each = each.value.cni_config.calico_config != null ? [each.value.cni_config.calico_config] : []
      content {
        dynamic "ip_pool_config" {
          for_each = calico_config.value.ip_pool_configs
          content {
            cidr = ip_pool_config.value.cidr
          }
        }
      }
    }
  }

  worker_node_pool {
    name            = each.value.worker_node_pool.name
    node_os_version = each.value.worker_node_pool.node_os_version
    num_instances   = each.value.worker_node_pool.num_instances
    ahv_config {
      cpu                        = each.value.worker_node_pool.ahv_config.cpu
      disk_mib                   = each.value.worker_node_pool.ahv_config.disk_mib
      memory_mib                 = each.value.worker_node_pool.ahv_config.memory_mib
      network_uuid               = each.value.worker_node_pool.ahv_config.network_uuid
      prism_element_cluster_uuid = each.value.worker_node_pool.ahv_config.prism_element_cluster_uuid
    }
  }

  etcd_node_pool {
    name            = each.value.etcd_node_pool.name
    node_os_version = each.value.etcd_node_pool.node_os_version
    num_instances   = each.value.etcd_node_pool.num_instances
    ahv_config {
      cpu                        = each.value.etcd_node_pool.ahv_config.cpu
      disk_mib                   = each.value.etcd_node_pool.ahv_config.disk_mib
      memory_mib                 = each.value.etcd_node_pool.ahv_config.memory_mib
      network_uuid               = each.value.etcd_node_pool.ahv_config.network_uuid
      prism_element_cluster_uuid = each.value.etcd_node_pool.ahv_config.prism_element_cluster_uuid
    }
  }

  master_node_pool {
    name            = each.value.master_node_pool.name
    node_os_version = each.value.master_node_pool.node_os_version
    num_instances   = each.value.master_node_pool.num_instances
    ahv_config {
      cpu                        = each.value.master_node_pool.ahv_config.cpu
      disk_mib                   = each.value.master_node_pool.ahv_config.disk_mib
      memory_mib                 = each.value.master_node_pool.ahv_config.memory_mib
      network_uuid               = each.value.master_node_pool.ahv_config.network_uuid
      prism_element_cluster_uuid = each.value.master_node_pool.ahv_config.prism_element_cluster_uuid
    }
  }

  dynamic "single_master_config" {
    for_each = each.value.single_master_config != null ? [each.value.single_master_config] : []
    content {
      # Empty block for single master mode
    }
  }

  dynamic "active_passive_config" {
    for_each = each.value.active_passive_config != null ? [each.value.active_passive_config] : []
    content {
      external_ipv4_address = active_passive_config.value.external_ipv4_address
    }
  }

  dynamic "external_lb_config" {
    for_each = each.value.external_lb_config != null ? [each.value.external_lb_config] : []
    content {
      external_ipv4_address = external_lb_config.value.external_ipv4_address
      dynamic "master_nodes_config" {
        for_each = external_lb_config.value.master_nodes_config != null ? external_lb_config.value.master_nodes_config : []
        content {
          ipv4_address = master_nodes_config.value.ipv4_address
          # TODO: node_name is not supported in nutanix provider v2.3.1
          # node_name    = master_nodes_config.value.node_name
        }
      }
    }
  }

  dynamic "private_registry" {
    for_each = each.value.private_registries != null ? each.value.private_registries : []
    content {
      registry_name = private_registry.value.registry_name
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [
      storage_class_config
    ]
  }
}

resource "nutanix_karbon_private_registry" "registry" {
  for_each = var.private_registries

  name     = each.value.name
  cert     = each.value.cert
  url      = each.value.url
  port     = each.value.port
  username = each.value.username
  password = each.value.password

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}
