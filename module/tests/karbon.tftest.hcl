###################################
# Unit Tests: Karbon (NKE) module
###################################

#########################
# Provider
#########################

provider "nutanix" {
  username = "dummy"
  password = "dummy"
  endpoint = "dummy.local"
  port     = 9440
  insecure = true
}

#########################
# Mock Data (Nutanix Provider)
#########################

mock_provider "nutanix" {

  # Per-cluster kubeconfig lookup used by module/data.tf to assemble kubeconfigs.
  mock_data "nutanix_karbon_cluster_kubeconfig" {
    defaults = {
      access_token           = "mock-access-token"
      cluster_ca_certificate = "bW9jay1jYQ=="
      cluster_url            = "https://mock-cluster.local:443"
      name                   = "mock-cluster"
    }
  }
}

#########################
# Tests
#########################

# Test 1: Empty configuration plans no resources.
run "empty_config" {
  command = plan

  variables {
    clusters           = {}
    private_registries = {}
  }

  assert {
    condition     = length(output.cluster_ids) == 0
    error_message = "Expected no clusters for an empty configuration"
  }

  assert {
    condition     = output.karbon_summary.total_clusters == 0 && output.karbon_summary.total_worker_nodes == 0
    error_message = "Expected the summary to report zero clusters and zero worker nodes"
  }
}

# Test 2: One cluster + one registry populates the id/summary outputs.
run "single_cluster_and_registry" {
  command = plan

  variables {
    private_registries = {
      reg = {
        name = "enterprise-registry"
        url  = "registry.example.local"
        port = 443
      }
    }

    clusters = {
      dev = {
        name    = "k8s-dev"
        version = "1.26.8-1"

        cni_config = {
          node_cidr_mask_size = 24
          pod_ipv4_cidr       = "172.20.0.0/16"
          service_ipv4_cidr   = "172.19.0.0/16"
          flannel_config      = {}
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

  assert {
    condition     = length(output.cluster_ids) == 1 && contains(keys(output.cluster_ids), "dev")
    error_message = "Expected exactly one cluster keyed 'dev'"
  }

  assert {
    condition     = length(output.registry_ids) == 1 && contains(keys(output.registry_ids), "reg")
    error_message = "Expected exactly one registry keyed 'reg'"
  }

  assert {
    condition     = output.karbon_summary.total_clusters == 1 && output.karbon_summary.total_registries == 1
    error_message = "Expected the summary to report one cluster and one registry"
  }

  assert {
    condition     = output.karbon_summary.total_worker_nodes == 1 && output.karbon_summary.total_etcd_nodes == 1
    error_message = "Expected the summary to report one worker node and one etcd node"
  }
}

# Test 3: Cluster without a name fails validation.
run "cluster_missing_name" {
  command = plan

  variables {
    clusters = {
      bad = {
        name    = ""
        version = "1.26.8-1"

        cni_config = {
          node_cidr_mask_size = 24
          pod_ipv4_cidr       = "172.20.0.0/16"
          service_ipv4_cidr   = "172.19.0.0/16"
          flannel_config      = {}
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

  expect_failures = [var.clusters]
}

# Test 4: Cluster without a version fails validation.
run "cluster_missing_version" {
  command = plan

  variables {
    clusters = {
      bad = {
        name    = "k8s-dev"
        version = ""

        cni_config = {
          node_cidr_mask_size = 24
          pod_ipv4_cidr       = "172.20.0.0/16"
          service_ipv4_cidr   = "172.19.0.0/16"
          flannel_config      = {}
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

  expect_failures = [var.clusters]
}

# Test 5: Master pool with 2 instances (not 1 or 3) fails validation.
run "cluster_invalid_master_count" {
  command = plan

  variables {
    clusters = {
      bad = {
        name    = "k8s-dev"
        version = "1.26.8-1"

        cni_config = {
          node_cidr_mask_size = 24
          pod_ipv4_cidr       = "172.20.0.0/16"
          service_ipv4_cidr   = "172.19.0.0/16"
          flannel_config      = {}
        }

        master_node_pool = {
          name            = "master"
          node_os_version = "ntnx-1.6"
          num_instances   = 2
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

  expect_failures = [var.clusters]
}

# Test 6: Etcd pool with 2 instances (not 1 or 3) fails validation.
run "cluster_invalid_etcd_count" {
  command = plan

  variables {
    clusters = {
      bad = {
        name    = "k8s-dev"
        version = "1.26.8-1"

        cni_config = {
          node_cidr_mask_size = 24
          pod_ipv4_cidr       = "172.20.0.0/16"
          service_ipv4_cidr   = "172.19.0.0/16"
          flannel_config      = {}
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
          num_instances   = 2
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

  expect_failures = [var.clusters]
}

# Test 7: CNI config selecting neither Flannel nor Calico fails validation.
run "cluster_missing_cni" {
  command = plan

  variables {
    clusters = {
      bad = {
        name    = "k8s-dev"
        version = "1.26.8-1"

        cni_config = {
          node_cidr_mask_size = 24
          pod_ipv4_cidr       = "172.20.0.0/16"
          service_ipv4_cidr   = "172.19.0.0/16"
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

  expect_failures = [var.clusters]
}

# Test 8: Private registry without a URL fails validation.
run "registry_missing_url" {
  command = plan

  variables {
    clusters = {}
    private_registries = {
      bad = {
        name = "enterprise-registry"
        url  = ""
        port = 443
      }
    }
  }

  expect_failures = [var.private_registries]
}
