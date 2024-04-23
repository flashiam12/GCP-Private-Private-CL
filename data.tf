data "confluent_environment" "default" {
  display_name = var.confluent_env
}

data "confluent_kafka_cluster" "cluster-0" {
  id = module.confluent-private-0.confluent_cluster_id
  environment {
    id = data.confluent_environment.default.id
  }
  depends_on = [ module.confluent-private-0 ]
}

data "confluent_kafka_cluster" "cluster-1" {
  id = module.confluent-private-1.confluent_cluster_id
  environment {
    id = data.confluent_environment.default.id
  }
  depends_on = [ module.confluent-private-1 ]
}

data "confluent_kafka_cluster" "cluster-0-public" {
  id = module.confluent-public-0.confluent_cluster_id
  environment {
    id = data.confluent_environment.default.id
  }
  depends_on = [ module.confluent-public-0 ]
}

data "confluent_network" "subnet-0" {
  display_name = module.confluent-private-0.confluent_network_name
  environment {
    id = data.confluent_environment.default.id
  }
  depends_on = [ module.confluent-private-0 ]
}

data "confluent_network" "subnet-1" {
  display_name = module.confluent-private-1.confluent_network_name
  environment {
    id = data.confluent_environment.default.id
  }
  depends_on = [ module.confluent-private-1 ]
}