## AWS
# current account id
variable "account_id" {
  default = "693466633220"
}


variable "default_vpc_cidr" {}
variable "default_subnet_a_cidr" {}
variable "default_subnet_b_cidr" {}
variable "default_subnet_c_cidr" {}

# outbound cidr for trusted ips
variable "trusted_cidrs" {
  type = "list"
  default = [
    "0.0.0.0/0"
  ]
}

variable "create_dns" {
  default = false
}

#Additional access to License Server
variable "license_api_trusted_cidr" {
  type = "list"
  default = []
}

variable "region" {
  default = "eu-west-2"
}

variable "state_bucket" {}

variable "profile" {}

## General
variable "environment" {}

variable "splunk_ami" {
  default = ""
}

variable "slack_alerts_channel" {}


variable "dns_base_domain" {
  default = "localhost"
}

variable "enable_n3_proxy_endpoint" {
  default = 1
}

variable "custom_s3_bucket_access" {
  default = []
  type = "list"
}

variable "pki_cn_name" {
  default = "splunk.internal"
}

variable "ssl_config" {
  type = "map"
  default = {
    ssl_country = "GB",
    ssl_state = "Your State",
    ssl_city = "Your City",
    ssl_org = "Your OrgName",
    ssl_orgunit = "Splunk",
    ssl_email = "you@youremail.com"
  }
}

variable "management_ami" {
  default = ""
}
variable "apps_git_repo" {
  default = ""
}

//Feature toggles
variable "enable_splunk_searchhead" {
  default = 1
}
variable "enable_splunk_master" {
  default = 1
}
variable "enable_splunk_license" {
  default = 1
}
variable "enable_splunk_indexer" {
  default = 1
}
variable "enable_splunk_forwarder" {
  default = 1
}

//Scale toggles
variable "scale_splunk_forwarder" {
  type = "map"
  default = {
    eu-west-2a = 2
    eu-west-2b = 0
  }
}
variable "scale_splunk_indexer" {
  type = "map"
  default = {
    eu-west-2a = 2
    eu-west-2b = 0
  }
}
variable "scale_splunk_searchhead" {
  type = "map"
  default = {
    eu-west-2a = 2
    eu-west-2b = 1
  }
}
variable "scale_splunk_master" {
  type = "map"
  default = {
    eu-west-2a = 1
    eu-west-2b = 0
  }
}
variable "scale_splunk_license" {
  type = "map"
  default = {
    eu-west-2a = 1
    eu-west-2b = 0
  }
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

variable "additional_sts_roles" {
  type = "list"
  default = []
}
