resource "aws_lb_target_group" "splunk_forwarder_hec" {
  count    = "${var.enable_splunk_forwarder}"
  port     = 8088
  protocol = "HTTPS"
  vpc_id   = "${lookup(local.vpcs["default"], "id")}"
  name     = "splunk-forwarder-hec"

  health_check {
    protocol = "HTTPS"
    matcher  = "200"
    path     = "/services/collector/health/1.0"
    interval = 30
  }
}

resource "aws_lb" "splunk_forwarder_hec" {
  count    = "${var.enable_splunk_forwarder}"
  name     = "splunk-forwarder-hec"
  internal = false

  enable_cross_zone_load_balancing = true
  load_balancer_type               = "application"
  enable_deletion_protection       = true

  //  access_logs {
  //    bucket = ""
  //    prefix = ""
  //  }

  subnets = [
    "${local.net_lists["default"]}",
  ]
  security_groups = [
    "${local.sg_ids["splunk_hec_alb"]}",
  ]
  tags {
    Name        = "splunk-fwd-hec-alb"
    Environment = "${var.environment}"
    source      = "terraform"
    project     = "core"
  }
}

resource "aws_lb_listener" "splunk_forwarder_hec" {
  count = "${var.enable_splunk_forwarder}"

  default_action {
    target_group_arn = "${aws_lb_target_group.splunk_forwarder_hec.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.splunk_forwarder_hec.arn}"
  protocol          = "HTTPS"
  port              = 443
  certificate_arn   = "${aws_acm_certificate.splunk_forwarder_hec.arn}"
}

resource "aws_acm_certificate" "splunk_forwarder_hec" {
  count       = "${var.enable_splunk_forwarder}"
  domain_name = "hec.${lookup(local.dns["public-audit"], "name")}"

  //subject_alternative_names = ["hec.${lookup(local.dns["public-audit"], "name")}"]
  validation_method = "DNS"

  tags {
    Environment = "${var.environment}"
    source      = "terraform"
    project     = "core"
    Name        = "${lookup(local.dns["public-audit"], "name")}"
  }
}

resource "aws_acm_certificate_validation" "hec-forwarder" {
  count           = "${var.enable_splunk_forwarder}"
  certificate_arn = "${aws_acm_certificate.splunk_forwarder_hec.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.acm_validation_hec.fqdn}",
  ]
}

resource "aws_route53_record" "acm_validation_hec" {
  count   = "${var.enable_splunk_forwarder}"
  zone_id = "${lookup(local.dns["public-audit"], "zone_id")}"

  name = "${aws_acm_certificate.splunk_forwarder_hec.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.splunk_forwarder_hec.domain_validation_options.0.resource_record_type}"

  records = [
    "${aws_acm_certificate.splunk_forwarder_hec.domain_validation_options.0.resource_record_value}",
  ]

  ttl = 60
}
