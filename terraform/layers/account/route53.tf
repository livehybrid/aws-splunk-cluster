resource "aws_route53_zone" "public-audit" {
  name = "${var.dns_base_domain}"

  tags {
    environment = "${var.environment}"
    project     = "audit"
  }
  count = "${var.create_dns ? 1 : 0}"
}

data "aws_route53_zone" "public-audit" {
  name = "${var.dns_base_domain}"
}

// this is mainly to update the TTL to make it faster to manage these if destroyed
resource "aws_route53_record" "public-audit-ns" {
  zone_id = "${data.aws_route53_zone.public-audit.zone_id}"
  name = "${data.aws_route53_zone.public-audit.name}"
  type    = "NS"
  ttl     = 30

  records = [
    "${data.aws_route53_zone.public-audit.name_servers.0}",
    "${data.aws_route53_zone.public-audit.name_servers.1}",
    "${data.aws_route53_zone.public-audit.name_servers.2}",
    "${data.aws_route53_zone.public-audit.name_servers.3}",
  ]
}

resource "aws_route53_zone" "private-audit" {
  name   = "${var.dns_base_domain}"
  vpc = {
    vpc_id = "${aws_vpc.default.id}"
  }

  tags {
    environment = "${var.environment}"
    project     = "core"
  }
}

// this is mainly to update the TTL to make it faster to manage these if destroyed
resource "aws_route53_record" "private-audit-ns" {
  zone_id = "${aws_route53_zone.private-audit.zone_id}"
  name    = "${aws_route53_zone.private-audit.name}"
  type    = "NS"
  ttl     = 30

  records = [
    "${aws_route53_zone.private-audit.name_servers.0}",
    "${aws_route53_zone.private-audit.name_servers.1}",
    "${aws_route53_zone.private-audit.name_servers.2}",
    "${aws_route53_zone.private-audit.name_servers.3}",
  ]
}
