provider "google" {
  project = var.project_id
}

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "${var.kubeconfig}-${var.cluster_name}-${var.env_name}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = var.project_id
  name                   = "${var.cluster_name}-${var.env_name}"
  regional               = true
  region                 = var.region
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  remove_default_node_pool = true
  monitoring_service       = var.monitoring_service
  logging_service          = var.logging_service
  node_pools = [
    {
      name                      = var.node_pools_1
      machine_type              = var.machine_type_node_pools_1
      node_locations            = var.node_pools_1_node_locations
      min_count                 = var.node_pools_1_min_count_nodes
      max_count                 = var.node_pools_1_max_count_nodes
      disk_size_gb              = var.node_pools_1_disk_size_gb
    },
    {
      name                      = var.node_pools_2
      machine_type              = var.machine_type_node_pools_2
      node_locations            = var.node_pools_2_node_locations
      min_count                 = var.node_pools_2_min_count_nodes
      max_count                 = var.node_pools_2_max_count_nodes
      disk_size_gb              = var.node_pools_2_disk_size_gb
   },
  ]
  node_pools_taints = {
    infra-pool = [
      {
        key    = "node-role"
        value  = "infra"
        effect = "NO_SCHEDULE"
      }
    ]
  }

}
