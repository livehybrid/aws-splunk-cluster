module "default-vpc-us-east-2" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "us-east-2"
}

module "default-sgs-us-east-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "us-east-1"
}

module "default-sgs-us-west-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "us-west-1"
}

module "default-sgs-us-west-2" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "us-west-2"
}

module "default-sgs-ap-south-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "ap-south-1"
}

//module "default-sgs-ap-northeast-3" {
//  source = "../../modules/default_vpc"
//  profile = "${var.profile}"
//  region = "ap-northeast-3"
//}

module "default-sgs-ap-northeast-2" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "ap-northeast-2"
}

module "default-sgs-ap-southeast-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "ap-southeast-1"
}

module "default-sgs-ap-southeast-2" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "ap-southeast-2"
}

module "default-sgs-ap-northeast-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "ap-northeast-1"
}

module "default-sgs-ca-central-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "ca-central-1"
}

//module "default-sgs-cn-north-1" {
//  source = "../../modules/default_vpc"
//  profile = "${var.profile}"
//  region = "cn-north-1"
//}

//module "default-sgs-cn-northwest-1" {
//  source = "../../modules/default_vpc"
//  profile = "${var.profile}"
//  region = "cn-northwest-1"
//}

module "default-sgs-eu-central-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "eu-central-1"
}

module "default-sgs-eu-west-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "eu-west-1"
}

module "default-sgs-eu-west-2" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "eu-west-2"
}

module "default-sgs-eu-west-3" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "eu-west-3"
}

module "default-sgs-eu-north-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "eu-north-1"
}

module "default-sgs-sa-east-1" {
  source = "../../modules/default_vpc"
  profile = "${var.profile}"
  region = "sa-east-1"
}