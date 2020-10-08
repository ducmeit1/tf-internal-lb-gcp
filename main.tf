# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY AN INTERNAL LOAD BALANCER
# This module deploys an Internal TCP/UDP Load Balancer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# CREATE FORWARDING RULE
# ------------------------------------------------------------------------------

resource "google_compute_forwarding_rule" "default" {
  provider              = google-beta
  project               = var.gcp_project
  name                  = var.name
  region                = var.gcp_region
  network               = var.gcp_network
  subnetwork            = var.gcp_subnetwork
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.default.self_link
  ip_address            = var.ip_address
  ip_protocol           = var.protocol
  ports                 = var.ports

  # If service label is specified, it will be the first label of the fully qualified service name.
  # Due to the provider failing with an empty string, we're setting the name as service label default
  service_label = var.service_label == "" ? var.name : var.service_label

  # This is a beta feature
  labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# CREATE BACKEND SERVICE
# ------------------------------------------------------------------------------

resource "google_compute_region_backend_service" "default" {
  project          = var.gcp_project
  name             = var.name
  region           = var.gcp_region
  protocol         = var.protocol
  timeout_sec      = 10
  session_affinity = var.session_affinity

  dynamic "backend" {
    for_each = var.backends
    content {
      description = lookup(backend.value, "description", null)
      group       = lookup(backend.value, "group", null)
    }
  }

  health_checks = [
    compact(
      concat(
        google_compute_health_check.tcp.*.self_link,
        google_compute_health_check.http.*.self_link
      )
  )[0]]
}

# ------------------------------------------------------------------------------
# CREATE HEALTH CHECK - ONE OF ´http´ OR ´tcp´
# ------------------------------------------------------------------------------

resource "google_compute_health_check" "tcp" {
  count = var.http_health_check ? 0 : 1

  project = var.gcp_project
  name    = format("%s-hc", var.name)

  tcp_health_check {
    port = var.health_check_port
  }
}

resource "google_compute_health_check" "http" {
  count = var.http_health_check ? 1 : 0

  project = var.gcp_project
  name    = format("%s-hc", var.name)

  http_health_check {
    host          = var.health_check_host
    port          = var.health_check_port
    request_path  = var.health_check_request_path
    proxy_header  = var.health_check_proxy_header
    response      = var.health_check_response
  }
}

# ------------------------------------------------------------------------------
# CREATE FIREWALLS FOR THE LOAD BALANCER AND HEALTH CHECKS
# ------------------------------------------------------------------------------

# Load balancer firewall allows ingress traffic from instances tagged with any of the ´var.source_tags´
resource "google_compute_firewall" "load_balancer" {
  project = var.gcp_network_project == "" ? var.gcp_project : var.gcp_network_project
  name    = format("%s-ilb-fw", var.name)
  network = var.gcp_network

  allow {
    protocol = lower(var.protocol)
    ports    = var.ports
  }

  # Source tags defines a source of traffic as coming from the primary internal IP address
  # of any instance having a matching network tag.
  source_tags = var.source_tags

  # Target tags define the instances to which the rule applies
  target_tags = var.target_tags
}

# Health check firewall allows ingress tcp traffic from the health check IP addresses
resource "google_compute_firewall" "health_check" {
  project = var.gcp_network_project_id == "" ? var.gcp_project : var.gcp_network_project_id
  name    = format("%s-hc", var.name)
  network = var.gcp_network

  allow {
    protocol = "tcp"
    ports    = [var.health_check_port]
  }

  # These IP ranges are required for health checks
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  # Target tags define the instances to which the rule applies
  target_tags = var.target_tags
}