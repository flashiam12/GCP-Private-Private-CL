terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.66.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_api_key   
  cloud_api_secret = var.confluent_api_secret 
}

provider "google" {
  project = var.gcp_project_id
}

provider "google" {
  alias = "google-west4"
  project = var.gcp_project_id
  region = local.gcp_regions[0]
}

provider "google" {
  alias = "google-west2"
  project = var.gcp_project_id
  region = local.gcp_regions[1]
}

locals {
  gcp_regions = ["us-west4", "us-west2"]
}

module "confluent-private-0" {
  source = "./confluent"
  confluent_private_cluster = true
  confluent_gcp_region = local.gcp_regions[0]
  confluent_cluster_env = data.confluent_environment.default.display_name
  confluent_cluster_name = "dexcom-private-${local.gcp_regions[0]}"
  confluent_network_name = "dexcom-${local.gcp_regions[0]}-subnet"
  providers = {
    confluent = confluent
  }
  gcp_project_id = var.gcp_project_id
}

module "confluent-private-1" {
  source = "./confluent"
  confluent_private_cluster = true
  confluent_gcp_region = local.gcp_regions[1]
  confluent_cluster_env = data.confluent_environment.default.display_name
  confluent_cluster_name = "dexcom-private-${local.gcp_regions[1]}"
  confluent_network_name = "dexcom-${local.gcp_regions[1]}-subnet"
  providers = {
    confluent = confluent
  }
  gcp_project_id = var.gcp_project_id
}

module "confluent-public-0" {
  source = "./confluent"
  confluent_private_cluster = false
  confluent_gcp_region = local.gcp_regions[0]
  confluent_cluster_env = data.confluent_environment.default.display_name
  confluent_cluster_name = "dexcom-public-${local.gcp_regions[0]}"
  confluent_network_name = "dexcom-${local.gcp_regions[0]}-subnet"
  providers = {
    confluent = confluent
  }
  gcp_project_id = var.gcp_project_id
}

module "gcp-setup" {
  source = "./google"
  gcp_project_id = var.gcp_project_id
  gcp_network_name = "dexcom-ha-poc"
  gcp_compute_name = "dexcom-poc-host"
  gcp_subnet_regions = local.gcp_regions
  providers = {
    google = google
  }
}

module "private-link-0" {
  count = length(data.confluent_network.subnet-0.gcp)
  source = "./ccloud-connectivity/privatelink/gcp/terraform"
  project = var.gcp_project_id
  region = data.confluent_kafka_cluster.cluster-0.region
  network_name = module.gcp-setup.gcp_compute_network
  subnetwork_name = element(module.gcp-setup.gcp_compute_subnetwork,1)
  bootstrap = data.confluent_kafka_cluster.cluster-0.bootstrap_endpoint
  psc_service_attachments_by_zone = data.confluent_network.subnet-0.gcp[0].private_service_connect_service_attachments
  providers = {
    google: google.google-west4
  }
  depends_on = [ module.confluent-private-0, module.gcp-setup ]
}

module "private-link-1" {
  count = length(data.confluent_network.subnet-1.gcp)
  source = "./ccloud-connectivity/privatelink/gcp/terraform"
  project = var.gcp_project_id
  region = data.confluent_kafka_cluster.cluster-1.region
  network_name = module.gcp-setup.gcp_compute_network
  subnetwork_name = element(module.gcp-setup.gcp_compute_subnetwork, 0)
  bootstrap = data.confluent_kafka_cluster.cluster-1.bootstrap_endpoint
  psc_service_attachments_by_zone = data.confluent_network.subnet-1.gcp[0].private_service_connect_service_attachments
  providers = {
    google: google.google-west2
  }
  depends_on = [ module.confluent-private-1, module.gcp-setup ]
}
