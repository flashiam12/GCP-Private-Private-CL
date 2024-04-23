output "gcp_compute_engine" {
  value = [google_compute_instance.default.*.name]
}

output "gcp_compute_engine_ip" {
  value = [google_compute_address.default.*.address]
}

output "gcp_compute_network" {
  value = module.vpc.network_name
}

output "gcp_compute_subnetwork" {
  value = module.vpc.subnets_names
}

output "gcp_compute_subnets" {
  value = module.vpc.subnets
}