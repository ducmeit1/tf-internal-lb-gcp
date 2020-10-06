# Provision Internal Load Balancer on GCP with Terraform

This module will provision an internal load balancer on GCP with Terraform.

## Introduction

### What is Cloud Load Balancing?

[Cloud Load Balancing](https://cloud.google.com/load-balancing/) is a fully distributed, software-defined, managed service for all your traffic. It is not an instance or device based solution, so you won’t be locked into physical load balancing infrastructure or face the HA, scale and management challenges inherent in instance based LBs. Cloud Load Balancing features include:

Internal TCP/UDP Load Balancing: load balance internal traffic.

### Internal TCP/UDP Load Balancer Terminology

GCP uses non-standard vocabulary for load balancing concepts. In case you're unfamiliar with load balancing on GCP, here's a short guide:

Internal IP address is the address for the load balancer. The internal IP address must be in the same subnet as the internal forwarding rule. The subnet must be in the same region as the backend service.
Internal forwarding rules in combination with the internal IP address is the frontend of the load balancer. It defines the protocol and port(s) that the load balancer accepts, and it directs traffic to a regional internal backend service.
Regional internal backend service defines the protocol used to communicate with the backends (instance groups), and it specifies a health check. Backends can be unmanaged instance groups, managed zonal instance groups, or managed regional instance groups.
Health check defines the parameters under which GCP considers the backends it manages to be eligible to receive traffic. Only healthy VMs in the backend instance groups will receive traffic sent from client VMs to the IP address of the load balancer.

## Usages

```hcl

locals {
    name                = "my-internal-lb"
    region              = "asia-southeast1"
    project             = "driven-stage-269911"
    network             = "my-network"
    subnetwork          = "my-subnetwork"
    port                = 80
    http_health_check   = true
    custom_labels       = ["ilb"]
}

module "internal-lb" {
    source  = "github.com/ducmeit1/tf-internal-lb-gcp"
    name    = local.name
    gcp_region  = local.region
    gcp_project = local.project
    
    backend = [
        {
            description = "Instance group for internal-load-balancer"
            group       = google_compute_instance_group.ig.self_link
        }
    ]

    # This setting will enable internal DNS for the load balancer
    service_label = local.name

    gcp_network     = local.network
    gcp_subnetwork  = local.subnetwork

    health_check_port   = local.port
    http_health_check   = local.http_health_check
    target_tags         = [local.name]
    source_tags         = [local.name]
    ports               = [local.port]

    custom_labels       = [local.custom_labels]
}
```

```shell
terraform plan
terraform apply
```