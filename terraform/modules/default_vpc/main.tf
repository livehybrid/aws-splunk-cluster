provider "aws" {
  alias = "custom"
  region = "${var.region}"

  profile = "${var.profile}"
  skip_credentials_validation = true
}


##################################################
### Start configurations of default sg clean   ###
##################################################


resource "aws_default_security_group" "default" {
  provider = "aws.custom"#"aws.region-${var.region}"
  vpc_id = "${aws_default_vpc.default.id}"
}
resource "aws_default_vpc" "default" {
  provider = "aws.custom"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${aws_default_vpc.default.id}"
  provider = "aws.custom"
}

resource "aws_default_network_acl" "default" {
  provider = "aws.custom"
  default_network_acl_id = "${aws_default_vpc.default.default_network_acl_id}"
  subnet_ids = ["${data.aws_subnet_ids.default.ids}"]
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  count        = "${var.include_nacl}"
}

variable "region" {}
variable "profile" {}
variable "include_nacl" {
  default = 1
}