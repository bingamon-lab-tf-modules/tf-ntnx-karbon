variable "enable_data_lookups" {
  description = "Enable data source lookups for existing clusters and registries"
  type        = bool
  default     = false
}

variable "clusters" {
  description = "Map of Karbon Kubernetes clusters to create"
  type = map(object({
    name    = string
    version = string

    storage_class_config = object({
      name           = string
      reclaim_policy = string
      volumes_config = object({
        file_system                = string
        flash_mode                 = bool
        password                   = string
        prism_element_cluster_uuid = string
        storage_container          = string
        username                   = string
      })
    })

    cni_config = object({
      node_cidr_mask_size = number
      pod_ipv4_cidr       = string
      service_ipv4_cidr   = string
      flannel_config = optional(object({
        # Flannel is the default CNI
      }))
      calico_config = optional(object({
        ip_pool_configs = list(object({
          cidr = string
        }))
      }))
    })

    worker_node_pool = object({
      name            = string
      node_os_version = string
      num_instances   = number
      ahv_config = object({
        cpu                        = number
        disk_mib                   = number
        memory_mib                 = number
        network_uuid               = string
        prism_element_cluster_uuid = string
      })
    })

    etcd_node_pool = object({
      name            = string
      node_os_version = string
      num_instances   = number
      ahv_config = object({
        cpu                        = number
        disk_mib                   = number
        memory_mib                 = number
        network_uuid               = string
        prism_element_cluster_uuid = string
      })
    })

    master_node_pool = object({
      name            = string
      node_os_version = string
      num_instances   = number
      ahv_config = object({
        cpu                        = number
        disk_mib                   = number
        memory_mib                 = number
        network_uuid               = string
        prism_element_cluster_uuid = string
      })
    })

    single_master_config = optional(object({
      # Empty block for single master mode
    }))

    active_passive_config = optional(object({
      external_ipv4_address = string
    }))

    external_lb_config = optional(object({
      external_ipv4_address = string
      master_nodes_config = optional(list(object({
        ipv4_address = string
        node_name    = string
      })))
    }))

    private_registries = optional(list(object({
      registry_name = string
    })))

    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.clusters : v.name != null && v.name != ""
    ])
    error_message = "name is required for all Karbon clusters."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : v.version != null && v.version != ""
    ])
    error_message = "version is required for all Karbon clusters."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : contains([1, 3], v.master_node_pool.num_instances)
    ])
    error_message = "master_node_pool.num_instances must be 1 (dev) or 3 (HA)."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : contains([1, 3], v.etcd_node_pool.num_instances)
    ])
    error_message = "etcd_node_pool.num_instances must be 1 (dev) or 3 (HA)."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : (
        v.cni_config.calico_config != null ||
        v.cni_config.flannel_config != null
      )
    ])
    error_message = "Either calico_config or flannel_config must be specified in cni_config."
  }
}

variable "private_registries" {
  description = "Map of private registries for Karbon clusters"
  type = map(object({
    name     = string
    cert     = optional(string)
    url      = string
    port     = number
    username = optional(string)
    password = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.private_registries : v.name != null && v.name != ""
    ])
    error_message = "name is required for all Karbon private registries."
  }

  validation {
    condition = alltrue([
      for k, v in var.private_registries : v.url != null && v.url != ""
    ])
    error_message = "url is required for all Karbon private registries."
  }
}
