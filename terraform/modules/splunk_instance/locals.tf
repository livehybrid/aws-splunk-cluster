data "aws_ami" "splunk" {
  name_regex = "^splunk-web-.*"

  owners = [
    "self",
  ]

  most_recent = true
}

data "aws_route53_zone" "domain" {
  zone_id = "${lookup(local.dns["public-audit"], "zone_id")}"
}

locals {
  //${element(local.net["default_subnet_ids"], 0)}
  az_letter              = "${replace(element(split("-",var.availability_zone),2),"/\\d/","")}"
  ami_id                 = "${var.ami_id != ""? var.ami_id : data.aws_ami.splunk.image_id }"
  dns                    = "${var.dns}"
  net                    = "${var.net}"
  vpcs                   = "${var.vpcs}"
  vpc_id                 = "${lookup(local.vpcs["default"], "id")}"
  sg_id                  = "${var.sg_ids}"
  pass4SymmKey           = "${var.pass4SymmKey != "" ? var.pass4SymmKey : data.aws_secretsmanager_secret_version.pass4SymmKey.secret_string}"
  domain                 = "${data.aws_route53_zone.domain.name}"
  name                   = "${var.environment}-${var.role}"
  enable_idx_clustering  = "${var.enable_splunk_indexers}"
  additional_server_conf = "${data.template_file.master_server_idx_clustering.rendered}"
}
