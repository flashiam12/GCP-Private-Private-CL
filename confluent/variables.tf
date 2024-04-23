variable "confluent_private_cluster" {
    type = bool
    default = true
}

variable "confluent_gcp_region" {
    type = string
}

variable "confluent_cluster_env" {
    type = string
}

variable "confluent_cluster_name" {
  type = string
}

variable "confluent_network_name" {
  type = string
  default = "None"
}

variable "gcp_project_id" {
  type = string
}