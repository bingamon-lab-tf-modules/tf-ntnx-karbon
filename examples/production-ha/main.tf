################################################################################
# Karbon Production HA Cluster Example
################################################################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.4.2"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port     = var.nutanix_port
  insecure = var.nutanix_insecure
}

module "karbon" {
  source = "../../module"

  enable_data_lookups = true

  # Private registry for air-gapped deployment
  private_registries = {
    enterprise_registry = {
      name     = "enterprise-registry"
      url      = var.private_registry_url
      port     = 443
      username = var.private_registry_username
      password = var.private_registry_password
      cert     = var.private_registry_cert
    }
  }

  clusters = {
    prod_cluster = {
      name    = "k8s-prod"
      version = var.kubernetes_version

      cni_config = {
        node_cidr_mask_size = 24
        pod_ipv4_cidr       = "172.20.0.0/16"
        service_ipv4_cidr   = "172.19.0.0/16"

        calico_config = {
          ip_pool_configs = [
            {
              cidr = "172.20.0.0/16"
            }
          ]
        }
      }

      # HA master configuration with VRRP
      active_passive_config = {
        external_ipv4_address = var.master_vip
      }

      master_node_pool = {
        name            = "master"
        node_os_version = var.node_os_version
        num_instances   = 3 # HA requires 3 masters

        ahv_config = {
          cpu                        = 8
          disk_mib                   = 122880
          memory_mib                 = 16384
          network_uuid               = var.network_uuid
          prism_element_cluster_uuid = var.prism_element_cluster_uuid
        }
      }

      worker_node_pool = {
        name            = "worker"
        node_os_version = var.node_os_version
        num_instances   = 3

        ahv_config = {
          cpu                        = 8
          disk_mib                   = 245760
          memory_mib                 = 32768
          network_uuid               = var.network_uuid
          prism_element_cluster_uuid = var.prism_element_cluster_uuid
        }
      }

      etcd_node_pool = {
        name            = "etcd"
        node_os_version = var.node_os_version
        num_instances   = 3 # HA requires 3 etcd nodes

        ahv_config = {
          cpu                        = 4
          disk_mib                   = 81920
          memory_mib                 = 8192
          network_uuid               = var.network_uuid
          prism_element_cluster_uuid = var.prism_element_cluster_uuid
        }
      }

      storage_class_config = {
        name           = "default-storageclass"
        reclaim_policy = "Retain" # Production uses Retain

        volumes_config = {
          file_system                = "ext4"
          flash_mode                 = true # Use flash for production
          password                   = var.prism_element_password
          prism_element_cluster_uuid = var.prism_element_cluster_uuid
          storage_container          = var.storage_container
          username                   = var.prism_element_username
        }
      }

      private_registries = [
        {
          registry_name = "enterprise-registry"
        }
      ]

      timeouts = {
        create = "2h"
        update = "1h"
        delete = "30m"
      }
    }
  }
}

################################################################################
# Variables
################################################################################

variable "nutanix_username" {
  description = "Nutanix Prism Central username"
  type        = string
}

variable "nutanix_password" {
  description = "Nutanix Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Nutanix Prism Central endpoint"
  type        = string
}

variable "nutanix_port" {
  description = "Nutanix Prism Central port"
  type        = number
  default     = 9440
}

variable "nutanix_insecure" {
  description = "Allow insecure connection"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.26.8-1"
}

variable "node_os_version" {
  description = "Node OS version"
  type        = string
  default     = "ntnx-1.6"
}

variable "network_uuid" {
  description = "Network UUID for cluster nodes"
  type        = string
}

variable "prism_element_cluster_uuid" {
  description = "Prism Element cluster UUID"
  type        = string
}

variable "prism_element_username" {
  description = "Prism Element username for storage"
  type        = string
}

variable "prism_element_password" {
  description = "Prism Element password for storage"
  type        = string
  sensitive   = true
}

variable "storage_container" {
  description = "Storage container name"
  type        = string
}

variable "master_vip" {
  description = "Virtual IP for HA master nodes (VRRP)"
  type        = string
}

variable "private_registry_url" {
  description = "Private registry URL"
  type        = string
}

variable "private_registry_username" {
  description = "Private registry username"
  type        = string
}

variable "private_registry_password" {
  description = "Private registry password"
  type        = string
  sensitive   = true
}

variable "private_registry_cert" {
  description = "Private registry CA certificate (base64 encoded)"
  type        = string
  default     = null
}

################################################################################
# Outputs
################################################################################

output "cluster_id" {
  description = "Cluster ID"
  value       = module.karbon.cluster_ids["prod_cluster"]
}

output "kubeconfig" {
  description = "Kubeconfig for kubectl access"
  value       = module.karbon.cluster_kubeconfigs["prod_cluster"]
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.karbon.cluster_endpoints["prod_cluster"]
}

output "private_registry_id" {
  description = "Private registry ID"
  value       = module.karbon.registry_ids["enterprise_registry"]
}
