# tf-ntnx-karbon

## Table of Contents

## Overview

A description of the module goes here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_nutanix"></a> [nutanix](#requirement\_nutanix) | >= 2.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nutanix"></a> [nutanix](#provider\_nutanix) | 2.4.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [nutanix_karbon_cluster.cluster](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/karbon_cluster) | resource |
| [nutanix_karbon_private_registry.registry](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/karbon_private_registry) | resource |
| [nutanix_karbon_cluster_kubeconfig.cluster](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/karbon_cluster_kubeconfig) | data source |
| [nutanix_karbon_clusters.existing](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/karbon_clusters) | data source |
| [nutanix_karbon_private_registries.existing](https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/data-sources/karbon_private_registries) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Map of Karbon Kubernetes clusters to create | <pre>map(object({<br/>    name    = string<br/>    version = string<br/><br/>    storage_class_config = object({<br/>      name           = string<br/>      reclaim_policy = string<br/>      volumes_config = object({<br/>        file_system                = string<br/>        flash_mode                 = bool<br/>        password                   = string<br/>        prism_element_cluster_uuid = string<br/>        storage_container          = string<br/>        username                   = string<br/>      })<br/>    })<br/><br/>    cni_config = object({<br/>      node_cidr_mask_size = number<br/>      pod_ipv4_cidr       = string<br/>      service_ipv4_cidr   = string<br/>      flannel_config = optional(object({<br/>        # Flannel is the default CNI<br/>      }))<br/>      calico_config = optional(object({<br/>        ip_pool_configs = list(object({<br/>          cidr = string<br/>        }))<br/>      }))<br/>    })<br/><br/>    worker_node_pool = object({<br/>      name            = string<br/>      node_os_version = string<br/>      num_instances   = number<br/>      ahv_config = object({<br/>        cpu                        = number<br/>        disk_mib                   = number<br/>        memory_mib                 = number<br/>        network_uuid               = string<br/>        prism_element_cluster_uuid = string<br/>      })<br/>    })<br/><br/>    etcd_node_pool = object({<br/>      name            = string<br/>      node_os_version = string<br/>      num_instances   = number<br/>      ahv_config = object({<br/>        cpu                        = number<br/>        disk_mib                   = number<br/>        memory_mib                 = number<br/>        network_uuid               = string<br/>        prism_element_cluster_uuid = string<br/>      })<br/>    })<br/><br/>    master_node_pool = object({<br/>      name            = string<br/>      node_os_version = string<br/>      num_instances   = number<br/>      ahv_config = object({<br/>        cpu                        = number<br/>        disk_mib                   = number<br/>        memory_mib                 = number<br/>        network_uuid               = string<br/>        prism_element_cluster_uuid = string<br/>      })<br/>    })<br/><br/>    single_master_config = optional(object({<br/>      # Empty block for single master mode<br/>    }))<br/><br/>    active_passive_config = optional(object({<br/>      external_ipv4_address = string<br/>    }))<br/><br/>    external_lb_config = optional(object({<br/>      external_ipv4_address = string<br/>      master_nodes_config = optional(list(object({<br/>        ipv4_address = string<br/>        node_name    = string<br/>      })))<br/>    }))<br/><br/>    private_registries = optional(list(object({<br/>      registry_name = string<br/>    })))<br/><br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_data_lookups"></a> [enable\_data\_lookups](#input\_enable\_data\_lookups) | Enable data source lookups for existing clusters and registries | `bool` | `false` | no |
| <a name="input_private_registries"></a> [private\_registries](#input\_private\_registries) | Map of private registries for Karbon clusters | <pre>map(object({<br/>    name     = string<br/>    cert     = optional(string)<br/>    url      = string<br/>    port     = number<br/>    username = optional(string)<br/>    password = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoints"></a> [cluster\_endpoints](#output\_cluster\_endpoints) | Map of cluster keys to their Kubernetes API server endpoints |
| <a name="output_cluster_ids"></a> [cluster\_ids](#output\_cluster\_ids) | Map of cluster names to IDs |
| <a name="output_cluster_kubeconfigs"></a> [cluster\_kubeconfigs](#output\_cluster\_kubeconfigs) | Map of cluster keys to their kubeconfig |
| <a name="output_clusters"></a> [clusters](#output\_clusters) | Karbon cluster details |
| <a name="output_existing_cluster_ids"></a> [existing\_cluster\_ids](#output\_existing\_cluster\_ids) | Map of existing (data-lookup) Karbon cluster names to UUIDs. Populated only when enable\_data\_lookups is true. |
| <a name="output_existing_registry_endpoints"></a> [existing\_registry\_endpoints](#output\_existing\_registry\_endpoints) | Map of existing (data-lookup) private registry names to endpoints. Populated only when enable\_data\_lookups is true. |
| <a name="output_karbon_summary"></a> [karbon\_summary](#output\_karbon\_summary) | Summary of Karbon resources |
| <a name="output_outputs"></a> [outputs](#output\_outputs) | Aggregate of all module outputs (spec §7.6 contract, consumed by the landing zone as module.<x>.outputs). |
| <a name="output_registries"></a> [registries](#output\_registries) | Private registry details |
| <a name="output_registry_ids"></a> [registry\_ids](#output\_registry\_ids) | Map of registry names to UUIDs |
<!-- END_TF_DOCS -->
