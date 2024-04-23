data "google_compute_default_service_account" "default" {
}

data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_address" "default" {
  count = length(var.gcp_subnet_regions)
  region = var.gcp_subnet_regions[count.index]
  name = "${var.gcp_network_name}-${var.gcp_subnet_regions[count.index]}-compute-public-ip"
  network_tier = "STANDARD"
}


resource "google_compute_instance" "default" {
  count = length(var.gcp_subnet_regions)
  name         = "${var.gcp_compute_name}-${var.gcp_subnet_regions[count.index]}"
  machine_type = "f1-micro"
  zone         = "${var.gcp_subnet_regions[count.index]}-a"
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }
  network_interface {
    network = module.vpc.network_name
    subnetwork = "dexcom-ha-poc-subnet-${var.gcp_subnet_regions[count.index]}"
    access_config {
      nat_ip = element(google_compute_address.default.*.address, count.index)
      network_tier = "STANDARD"
    }
  }
  tags = [var.gcp_compute_name]
}