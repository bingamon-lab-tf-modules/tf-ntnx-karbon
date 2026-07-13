################################################################################
# tf-ntnx-karbon — minimal single-cluster example
#
# Deploys one development-sized Karbon (NKE) cluster: a single master, a single
# worker pool and a single etcd node, using the default Flannel CNI. Replace the
# placeholder UUIDs and credentials with values for your environment.
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
  # Supply credentials via NUTANIX_* environment variables or a *.tfvars file.
}

module "karbon" {
  source = "git::https://github.com/bingamon-lab-tf-modules/tf-ntnx-karbon.git//module?ref=v0.1.0"

  clusters = {
    dev_cluster = {
      name    = "k8s-dev"
      version = "1.26.8-1"

      cni_config = {
        node_cidr_mask_size = 24
        pod_ipv4_cidr       = "172.20.0.0/16"
        service_ipv4_cidr   = "172.19.0.0/16"

        # Flannel is the default CNI (empty block selects it).
        flannel_config = {}
      }

      single_master_config = {}

      master_node_pool = {
        name            = "master"
        node_os_version = "ntnx-1.6"
        num_instances   = 1

        ahv_config = {
          cpu                        = 4
          disk_mib                   = 122880
          memory_mib                 = 8192
          network_uuid               = "00000000-0000-0000-0000-000000000000"
          prism_element_cluster_uuid = "00000000-0000-0000-0000-000000000000"
        }
      }

      worker_node_pool = {
        name            = "worker"
        node_os_version = "ntnx-1.6"
        num_instances   = 1

        ahv_config = {
          cpu                        = 4
          disk_mib                   = 122880
          memory_mib                 = 8192
          network_uuid               = "00000000-0000-0000-0000-000000000000"
          prism_element_cluster_uuid = "00000000-0000-0000-0000-000000000000"
        }
      }

      etcd_node_pool = {
        name            = "etcd"
        node_os_version = "ntnx-1.6"
        num_instances   = 1

        ahv_config = {
          cpu                        = 4
          disk_mib                   = 40960
          memory_mib                 = 8192
          network_uuid               = "00000000-0000-0000-0000-000000000000"
          prism_element_cluster_uuid = "00000000-0000-0000-0000-000000000000"
        }
      }

      storage_class_config = {
        name           = "default-storageclass"
        reclaim_policy = "Delete"

        volumes_config = {
          file_system                = "ext4"
          flash_mode                 = false
          password                   = "changeme"
          prism_element_cluster_uuid = "00000000-0000-0000-0000-000000000000"
          storage_container          = "default-container"
          username                   = "admin"
        }
      }
    }
  }
}

################################################################################
# Outputs
################################################################################

output "cluster_id" {
  description = "ID of the created development cluster"
  value       = module.karbon.cluster_ids["dev_cluster"]
}

output "kubeconfig" {
  description = "Kubeconfig for kubectl access to the development cluster"
  value       = module.karbon.cluster_kubeconfigs["dev_cluster"]
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint for the development cluster"
  value       = module.karbon.cluster_endpoints["dev_cluster"]
}
