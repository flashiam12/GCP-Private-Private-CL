
# Private-Private Cluster Linking via Public Jump on GCP

This project is a live demonstration of Cluster link chaining. This is intended to be used as a demo to showcase cluster linking of two clusters in different regions on Google Cloud VPC. The idea is to use jump clusters with cluster chaining to achieve it. 




## Setup 

Here are the steps to setup the Jump cluster based private-private cluster linking with GCP and Confluent Cloud for Kafka clusters part of two different regions.

### Running Local Setup

#### 1. Prerequisite

##### a. Define Confluent Environment & Google Project

```console
export CONFLUENT_ENV=<YOUR_CC_ENVIRONMENT>
export GCP_PROJECT=<YOUR_GCP_PROJECT>
```
##### b. Authenticate to GCP and Confluent Cloud

```console
gcloud auth application-default login 
confluent login --save
```

##### c. Create Confluent Cloud Cloud API Key, Skip this step if you already have the Cloud API Key
```console
confluent api-keys create confluent api-key create --resource cloud --environment $CONFLUENT_ENV 
```
You will need the KEY and SECRET generated in this step in the next step.
##### d. Define the terraform tfvars
```console 
export TF_VAR_confluent_api_key=<CC_CLOUD_API_KEY>
export TF_VAR_confluent_api_secret=<CC_CLOUD_API_SECRET>
export TF_VAR_confluent_env=$CONFLUENT_ENV 
export TF_VAR_gcp_project_id=$GCP_PROJECT
```

#### 2. Infrastructure Setup
##### a. Initialize Terraform 
```console
terraform init
```
##### b. Define Terraform for GCP & Confluent Components
```console
terraform apply -target module.gcp-setup
terraform apply -target module.confluent-private-0  module.confluent-private-1 module.confluent-public-0
```

##### c. Define Private Link between Confluent & GCP
```console
terraform apply -target module.private-link-0 module.private-link-1
```

### Running Remote Setup
#### 1. GCP Init
GCP Auth for accessing GCE VM
```console
gcloud auth login
```
Get this value from the GCP console
```console
export GCP_WEST2_VM=<GCP_WEST2_VM_NAME>
export GCP_WEST4_VM=<GCP_WEST4_VM_NAME>
export GCP_WEST4_PUBLIC_VM=<GCP_WEST4_PUBLIC_VM_NAME>
```

#### 2. Forward Cluster Link Setup 

##### a. Remote Setup for West 4 Public Cluster
####
SSH into US West 4 Public
```console
gcloud compute ssh --zone "us-west2-a" $GCP_WEST2_VM --project $GCP_PROJECT
```

In the VM, run the following steps:

i. Setup basic tools
```console
sudo apt-get update && sudo apt-get install netcat default-jre default-jdk nginx -y

curl --output kafka.tgz https://dlcdn.apache.org/kafka/3.7.0/kafka_2.13-3.7.0.tgz

tar -xvf kafka.tgz && PATH=$PATH:~/kafka_2.13-3.7.0/bin

mkdir confluent && curl -sL --http1.1 https://cnfl.io/cli | sh -s -- -b ./confluent latest

export PATH=$(pwd)/confluent:$PATH
```
ii. Confluent Setup
```console
confluent login 
confluent env use $CONFLUENT_ENV
```
iii. Create 

##### b. Remote Setup for West 4 Private Cluster
##### c. Remote Setup for West 2 Private Cluster


#### 3. Reverse Cluster Link Setup 

##### a. Remote Setup for West 4 Public Cluster
##### b. Remote Setup for West 2 Private Cluster
##### c. Remote Setup for West 4 Private Cluster

### Runbook for Demo

#### 1. Setup producers & consumers
#### 2. Inject network connectivity issues
#### 3. Produce/Consume during network failure - Failover
#### 4. Produce/Consume after network failure - Failback 
#### 5. Teardown


## Documentation

[Documentation](https://docs.confluent.io/cloud/current/multi-cloud/cluster-linking/private-networking.html#cluster-link-chaining-and-jump-clusters)


## Demo

Insert gif or link to demo

