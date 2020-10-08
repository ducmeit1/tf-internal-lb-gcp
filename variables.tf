# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "gcp_project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "gcp_region" {
  description = "All resources will be launched in this region."
  type        = string
}

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "ports" {
  description = "List of ports (or port ranges) to forward to backend services. Max is 5."
  type        = list(string)
}

variable "health_check_port" {
  description = "Port to perform health checks on."
  type        = number
}

variable "health_check_host" {
  description = "Host to perform health checks on."
  type        = string
  default     = ""
}

variable "health_check_request_path" {
  description = "Request path to perform health checks on."
  type        = string
  default     = ""
}

variable "health_check_proxy_header" {
  description = "Proxy header to perform health checks on."
  type        = string
  default     = ""
}


variable "health_check_response" {
  description = "Response to perform health checks on."
  type        = string
  default     = ""
}

variable "backends" {
  description = "List of backends, should be a map of key-value pairs for each backend, must have the 'group' key."
  type        = list(map(string))
  # Example
  # backends = [
  #   {
  #     description = "Sample Instance Group for Internal LB",
  #     group       = "The fully-qualified URL of an Instance Group"
  #   }   
  # ]
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "gcp_network" {
  description = "Self link of the VPC network in which to deploy the resources."
  type        = string
}

variable "gcp_subnetwork" {
  description = "Self link of the VPC subnetwork in which to deploy the resources."
  type        = string
  default     = ""
}

variable "protocol" {
  description = "The protocol for the backend and frontend forwarding rule. TCP or UDP."
  type        = string
  default     = "TCP"
}

variable "ip_address" {
  description = "IP address of the load balancer. If empty, an IP address will be automatically assigned."
  type        = string
  default     = null
}

variable "service_label" {
  description = "An optional prefix to the service name for this Forwarding Rule. If specified, will be the first label of the fully qualified service name."
  type        = string
  default     = ""
}

variable "gcp_network_project_id" {
  description = "The name of the GCP Project where the network is located. Useful when using networks shared between projects. If empty, var.project will be used."
  type        = string
  default     = ""
}

variable "http_health_check" {
  description = "Set to true if health check is type http, otherwise health check is tcp."
  type        = bool
  default     = false
}

variable "session_affinity" {
  description = "The session affinity for the backends, e.g.: NONE, CLIENT_IP. Default is `NONE`."
  type        = string
  default     = "NONE"
}

variable "source_tags" {
  description = "List of source tags for traffic between the internal load balancer."
  type        = list(string)
  default     = []
}

variable "target_tags" {
  description = "List of target tags for traffic between the internal load balancer."
  type        = list(string)
  default     = []
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

variable "allow_global_access" {
  description = "Allow global access instead in regional. Other regional could access to the load balancer."
  type        = bool
  default     = false
}

variable "network_tier" {
  description = "Network tier to reverse IP Address. Use PREMIUM or STANDARD."
  type        = string
  default     = "PREMIUM"
}
