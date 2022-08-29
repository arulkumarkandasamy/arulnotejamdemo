variable "project_name" {
    type = string
    default = "silken-network-252121"
    description = "GCP Project Id"
}

variable "region" {
    type = string
    default = "us-east1"
    description = "GCP Region code"
}

variable "zone" {
    type = string
    default = "us-east1-b"
    description = "GCP availability zone"
}

variable "vpc_name" {
    type = string
    default = "notejam-vpc"
    description = "VPC network name"
}

variable "iam_roles" {
    type = map(string)
    default = {}
    description = "Project IAM roles"
}

variable "cluster_name" {
    type = string
    default = "develop"
    description = "Kubernetes cluster name"
}

variable "private_subnet_name" {
    type = string
    default = "notejam-private-subnet"
    description = "Private subnet name"
}

variable "public_subnet_name" {
    type = string
    default = "notejam-public-subnet"
    description = "Public subnet name"
}


variable "subnet_cidr" {
    type = string
    default = "10.1.0.0/16"
    description = "Subnet ip range"
}

variable "public_subnet_cidr" {
  type = string
    default = "10.2.0.0/16"
    description = "Subnet ip range"
}

variable "service_range" {
    type = string
    default = "172.16.10.0/24"
    description = "Server ip range"
}

variable "master_range" {
    type = string
    default = "172.16.2.0/28"
    description = "Kubernetes master ip range"
}

variable "pod_range" {
    type = string
    default = "10.249.0.0/20"
    description = "Kubernetes pod ip range"
}

variable "num_of_external_nat_ips" {  
  type        = number
  default     = 1
  description = "The number of external ips that should be created for the Cloud NAT"
}

variable "nat_attach_manual_ips" {  
  type        = string
  default     = "ALL"
  description = "The manual IPs"
}

variable "name_external_nat_ips" {  
  type        = string
  default     = "nat-manual-ip"
  description = "Name static nat ips"
}

variable "nat_timeout" {
  description = "NAT timeout"
  type        = string
  default     = "10m"
}

variable "nat_enable_endpoint_independent_mapping" {
  type        = bool  
  default     = false
  description = "Specifies if endpoint independent mapping is enabled"
}

variable "nat_min_ports_per_vm" {  
  type        = number
  default     = 64
  description = "Minimum number of ports reserved by the Cloud NAT for each VM"
}

variable "name_cloud_nat" {  
  type        = string
  default     = "cloud-nat"
  description = "Name for the Cloud NAT."
}

variable "notejam_pool_name" {
    type = string
    default = "notejam-pool"
    description = "Nodepool namee"
}

variable "notejam_pool_node_number" {
    type = string
    default = 1
    description = "Nodepool number"
}

variable "notejam_pool_min_node" {
    type = string
    default = 1
    description = "Min number of nodes"
}

variable "notejam_pool_max_node" {
    type = string
    default = 2
    description = "Max number of nodes"
}

variable "machine_type" {
    type = string
    default = "n1-standard-4"
    description = "Node machine type"
}

variable "service_account" {
    type = string
    default = ""
    description = "Kubernetes cluster service account name"
}

variable "configure_gke_networking" {
  type    = bool
  default = false
}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Flag to enable Private Endpoint on the cluster"
}

variable "name_suffix" {  
  type        = string
  default = "notejam"
  description = "Arbitrary suffix"
}

variable "common_resource_id" {
    type = string
    default = "notejam"
}

variable "gke_release_channel" {
  type    = string
  default = "REGULAR"
}

variable "pod_security_policy" {
  type        = bool
  description = "Enable pod security policy"
  default     = true
}

variable "cluster_autoscaling_config" {
  description = "Enable and configure limits for Node Auto-Provisioning with Cluster Autoscaler."
    type = object({
      enabled    = bool
      cpu_min    = number
      cpu_max    = number
      memory_min = number
      memory_max = number
    })
    default = {
      enabled    = false
      cpu_min    = 0
      cpu_max    = 0
      memory_min = 0
      memory_max = 0
    }
}

variable "generate_gke_service_account_key" {
  type    = bool
  default = false
}

variable "gke_service_account_iam_roles" {
  type    = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountTokenCreator",
  ]
}

variable "enable_workload_identity_config" {
  type        = bool
  description = "enable or disable workload identity config"
  default     = false
}

variable "disk_size_gb" {
  type = string
  default = "100"
  description = "Disk Size in GB"
}

variable "instance_name" {
  type = string
  default = "notejam-bastion"
  description = "Bastion host for IAP access"
}

variable "scopes" {
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "service_account_name" {
  default = "notejam-bastion"
  description = "The name of the service account instance"
}

variable "image" {
  description = "GCE image on which to base the Bastion"
  default = "gce-uefi-images/centos-7"
}

variable "shielded_vm" {
  description = "Must use a supported image if true"
  default = false
}

variable "tag" {
  default = "bastion-ssh"
}

variable "members" {
  default = ["user:arulkr1967@gmail.com", ]
}

variable "authorized_networks" {
  type = list(object({
    description = string,
    cidr_ranges = list(string)
  }))
  default = [
    { 
      description: "public_subnet",
      cidr_ranges: ["10.2.0.0/16", "10.1.0.0/16"]
    }
]
}

