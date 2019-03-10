provider "aws" {
  region  = "${var.region}"
  version = "~> 1.21"
  profile = "${var.profile}"

  skip_credentials_validation = true

  //  skip_get_ec2_platforms      = true
  //  skip_requesting_account_id  = true
  //  skip_region_validation      = true
}

provider "random" {
  version = "~> 1.0"
}

provider "external" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}
