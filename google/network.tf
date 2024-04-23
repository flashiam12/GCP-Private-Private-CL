locals {
    subnet_ips = cidrsubnets("10.10.0.0/18", 2,2)
    subnets = [for index, x in var.gcp_subnet_regions: 
                {
                    subnet_name           = "${var.gcp_network_name}-subnet-${x}"
                    subnet_ip             = local.subnet_ips[index]
                    subnet_region         = x
                    subnet_private_access = "true"
                    subnet_flow_logs      = "true"
                    subnet_flow_logs_interval = "INTERVAL_10_MIN"
                    subnet_flow_logs_sampling = 0.7
                    subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
                    description           = "Subnet for ${x} in ${var.gcp_network_name} created by STS"
                }
            ]
}

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 9.0"
    project_id   = var.gcp_project_id
    network_name = var.gcp_network_name
    routing_mode = "GLOBAL"
    subnets = local.subnets
    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
    ]   
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "google_compute_firewall" "rules" {
  project     = var.gcp_project_id
  name        = "default-ssh"
  network     = module.vpc.network_name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["22", "9092", "443"]
  }

  source_ranges = ["${chomp(data.http.myip.response_body)}/32"]
  target_tags = [var.gcp_compute_name]
}