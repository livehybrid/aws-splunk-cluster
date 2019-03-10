variable "ami_id" {
  default = ""
}

variable "sg_id" {}
variable "keypair_name" {}
variable "instance_profile_arn" {}

variable "name" {}

variable "min_size" {
  default = 1
}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "vpcs" {
  type = "map"
}

variable "net" {
  type = "map"
}

variable "dns" {
  type = "map"
}

variable "s3" {
  type = "map"
}


variable "instance_type" {
  default = "t2.large"
}