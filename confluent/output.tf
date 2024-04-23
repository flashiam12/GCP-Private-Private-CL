output "confluent_cluster_id" {
  value = var.confluent_private_cluster ? element(confluent_kafka_cluster.network_default.*.id, 0) : element(confluent_kafka_cluster.no_network_default.*.id, 0)
}

output "confluent_network_name" {
  value = var.confluent_private_cluster ? element(confluent_network.default.*.display_name, 0): var.confluent_network_name
}
