variable "project_id" {
  description = "project id"
  default = "geometric-orbit-325713"
}
variable "cluster_name" {
  description = "The test k8s otus cluster"
  default     = "gcp-cluster"
}
variable "env_name" {
  description = "The environment for the GKE cluster"
  default     = "prod"
}
variable "region" {
  description = "The region to host the cluster in"
  default     = "europe-west3"
}
variable "network" {
  description = "The VPC network created to host the cluster in"
  default     = "gke-network"
}
variable "subnetwork" {
  description = "The subnetwork created to host the cluster in"
  default     = "gke-subnet"
}
variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}
variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}
variable "node_pools_1" {
  description = "name of node_pools_1"
  default     = "default-pool"
}
variable "machine_type_node_pools_1" {
  description = "machine of node_pools_1"
  default     = "n1-standard-2"
}
variable "node_pools_1_min_count_nodes" {
  default     = "2"
}
variable "node_pools_1_max_count_nodes" {
  default     = "3"
}
variable "node_pools_1_disk_size_gb" {
  default     = "30"
}
variable "node_pools_1_node_locations" {
  default     = "europe-west3-a"
}
variable "node_pools_2" {
  description = "name of node_pools_2"
  default     = "node-pool"
}
variable "machine_type_node_pools_2" {
  description = "machine of node_pools_2"
  default     = "n1-standard-2"
}
variable "node_pools_2_min_count_nodes" {
  default     = "3"
}
variable "node_pools_2_max_count_nodes" {
  default     = "3"
}
variable "node_pools_2_disk_size_gb" {
  default     = "100"
}
variable "node_pools_2_node_locations" {
  default     = "europe-west3-a"
}
variable "kubeconfig" {
  default     = "/Users/antonchudin/.kube/conf.d/config"
}
variable "monitoring_service" {
  default     = "monitoring.googleapis.com/kubernetes"
}
variable "logging_service" {
  default     = "logging.googleapis.com/kubernetes"
}
