variable "instance_profile_name" {}
variable "keypair_name" {}
variable ami_id {}

variable "dns" {
  type = "map"
}

variable "vpcs" {
  type = "map"
}

variable "net" {
  type = "map"
}

variable "s3" {
  type = "map"
}

variable "sg_ids" {
  type = "map"
}

variable "instance_size" {
  default = "t2.large"
}

variable "extra_user_data" {
  default = ""
}

variable "role" {
}

variable "count" {
  default = 1
}

variable "ebs_optimized" {
  default = false
}

variable "os_volume_size" {
  default = 40
}

variable "asg_max_size" {
  default = 1
  description = "Usually 1 as we scale the number of ASG, not the ASG themselves..."
}

variable "asg_desired_size" {
  default = 1
}

variable "hot_disk_size" {
  default = 100
}

variable "cold_disk_size" {
  default = 100
}

variable "associate_public_ip_address" {
  default = false
}

variable "target_group" {
  default = ""
}

variable "security_groups" {
  type = "list"
}

variable "availability_zone" {}

## Splunk Settings
variable "httpport" {
  default = 8000
}

variable "indexer_volume_size" {
  default = "50"
}

variable "mgmtHostPort" {
  default = 8089
}

variable "pass4SymmKey" {
  default = ""
}

variable "replication_factor" {
  default = 1
}

variable "replication_port" {
  default = 9887
}

variable "search_factor" {
  default = 1
}

variable "cn_name" {
  default = ""
}

variable "apps_git_repo" {
  default = ""
}

variable "enabled" {
  default = 1
}

variable "enable_splunk_indexers" {
  default = 1
  description = "Used to determine if idx clustering should be enabled"
}
variable "splunkcloud_fwd" {
  default = ""
}

variable "splunk_admin_username" {
  default = "admin"
}

variable "oauth_server" {
  default = ""
}
variable "oauth_clientid" {
  default = ""
}
variable "oauth_clientsecret" {
  default = ""
}