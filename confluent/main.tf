data "confluent_environment" "default" {
  display_name = var.confluent_cluster_env
}


resource "confluent_network" "default" {
  count = var.confluent_private_cluster ? 1:0
  display_name     = "${var.confluent_cluster_name}-default-network"
  cloud            = "GCP"
  region           = var.confluent_gcp_region
  connection_types = ["PRIVATELINK"]
  zones            = ["${var.confluent_gcp_region}-a", "${var.confluent_gcp_region}-b", "${var.confluent_gcp_region}-c"]
  environment {
    id = data.confluent_environment.default.id
  }
  dns_config {
    resolution = "PRIVATE"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_private_link_access" "gcp" {
  count = var.confluent_private_cluster ? 1:0
  display_name = "gcp-private-link-${var.confluent_gcp_region}"
  gcp {
    project = var.gcp_project_id
  }
  environment {
    id = data.confluent_environment.default.id
  }
  network {
    id = confluent_network.default[count.index].id
  }

  lifecycle {
    prevent_destroy = false
  }
}


resource "confluent_kafka_cluster" "network_default" {
  count = var.confluent_private_cluster ? 1:0
  display_name = var.confluent_cluster_name
  availability = "MULTI_ZONE"
  cloud        = "GCP"
  region       = var.confluent_gcp_region
  dedicated {
    cku = 2
  }

  environment {
    id = data.confluent_environment.default.id
  }

  network {
    id = confluent_network.default[count.index].id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_cluster" "no_network_default" {
  count = var.confluent_private_cluster ? 0:1
  display_name = var.confluent_cluster_name
  availability = "MULTI_ZONE"
  cloud        = "GCP"
  region       = var.confluent_gcp_region
  dedicated {
    cku = 2
  }

  environment {
    id = data.confluent_environment.default.id
  }

  lifecycle {
    prevent_destroy = false
  }
}
