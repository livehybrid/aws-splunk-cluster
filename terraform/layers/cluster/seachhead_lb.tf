resource "aws_lb_target_group" "splunk_searchheads" {
  count    = "${var.enable_splunk_searchhead}"
  port     = 8443
  protocol = "HTTPS"
  vpc_id   = "${lookup(local.vpcs["default"], "id")}"
  name     = "splunk-searchheads"

  health_check {
    protocol = "HTTPS"
    matcher  = "403"
    path     = "/"
    interval = 30
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 43200
  }
}

resource "aws_lb" "splunk_searchheads" {
  count    = "${var.enable_splunk_searchhead}"
  name     = "splunk-searchheads"
  internal = false

  enable_cross_zone_load_balancing = true
  load_balancer_type               = "application"

  subnets = [
    "${local.net_lists["default"]}",
  ]

  security_groups = [
    "${local.sg_ids["splunk_searchhead_alb"]}",
  ]

  tags {
    Name        = "splunk-searchhead-alb"
    Environment = "${var.environment}"
    source      = "terraform"
    project     = "core"
  }
}

resource "aws_lb_listener" "splunk_searchheads" {
  count = "${var.enable_splunk_searchhead}"

  default_action {
    target_group_arn = "${aws_lb_target_group.splunk_searchheads.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.splunk_searchheads.arn}"
  protocol          = "HTTPS"
  port              = 443
  certificate_arn   = "${aws_acm_certificate.splunk_search.arn}"
}

resource "aws_acm_certificate" "splunk_search" {
  count       = "${var.enable_splunk_searchhead}"
  domain_name = "search.${lookup(local.dns["public-audit"], "name")}"

  //subject_alternative_names = ["hec.${lookup(local.dns["public-audit"], "name")}"]
  validation_method = "DNS"

  tags {
    Environment = "${var.environment}"
    source      = "terraform"
    project     = "core"
    Name        = "${lookup(local.dns["public-audit"], "name")}"
  }
}

resource "aws_acm_certificate_validation" "search" {
  count           = "${var.enable_splunk_searchhead}"
  certificate_arn = "${aws_acm_certificate.splunk_search.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.acm_validation_search.fqdn}",
  ]
}

resource "aws_route53_record" "acm_validation_search" {
  count   = "${var.enable_splunk_searchhead}"
  zone_id = "${lookup(local.dns["public-audit"], "zone_id")}"

  name = "${aws_acm_certificate.splunk_search.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.splunk_search.domain_validation_options.0.resource_record_type}"

  records = [
    "${aws_acm_certificate.splunk_search.domain_validation_options.0.resource_record_value}",
  ]

  ttl = 60
}

resource "aws_route53_record" "searchhead_lb" {
  count   = "${var.enable_splunk_searchhead}"
  zone_id = "${lookup(local.dns["public-audit"], "zone_id")}"
  name    = "search"
  type    = "CNAME"
  ttl     = "30"

  records = [
    "${aws_lb.splunk_searchheads.dns_name}",
  ]
}
