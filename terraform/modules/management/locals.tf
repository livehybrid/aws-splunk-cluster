data "aws_ami" "management" {
  name_regex  = "^core-ubuntu-base-.*"
  owners      = ["self"]
  most_recent = true
}

data "aws_route53_zone" "public" {
  zone_id = "${lookup(var.dns["public-audit"], "zone_id")}"
}

locals {
  ami_id = "${var.ami_id != ""? var.ami_id : data.aws_ami.management.image_id }"
  is_dev = "${var.environment == "dev"?1:0}"
  dns    = "${var.dns}"
  net    = "${var.net}"
  vpcs   = "${var.vpcs}"
  s3     = "${var.s3}"
  fqdn   = "${data.aws_route53_zone.public.name}"
}

