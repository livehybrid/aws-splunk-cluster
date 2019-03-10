resource "aws_lb" "splunk_license" {
  name     = "splunk-license"
  count    = "${var.enable_splunk_license}"
  internal = false

  #enable_cross_zone_load_balancing = true
  enable_deletion_protection = true

  load_balancer_type = "network"

  subnets = [
    "${values(local.net["default"])}",
  ]

  tags {
    Name        = "splunk-license"
    Environment = "${var.environment}"
    source      = "terraform"
    project     = "splunk"
  }
}

#Service Endpoint for License server

resource "aws_vpc_endpoint_service" "splunk_license" {
  count                      = "${var.enable_splunk_license}"
  acceptance_required        = false
  network_load_balancer_arns = ["${aws_lb.splunk_license.arn}"]

  depends_on = ["aws_lb.splunk_license"]
}

output "license_service_endpoint" {
  value = "${aws_vpc_endpoint_service.splunk_license.*.service_name}"
}

resource "aws_lb_listener" "splunk_license" {
  count = "${var.enable_splunk_license}"

  default_action {
    target_group_arn = "${aws_lb_target_group.splunk_license.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.splunk_license.arn}"
  protocol          = "TCP"
  port              = 443
}

resource "aws_lb_target_group" "splunk_license" {
  count    = "${var.enable_splunk_license}"
  port     = 443
  protocol = "TCP"
  vpc_id   = "${lookup(local.vpcs["default"],"id")}"
  name     = "splunk-license"

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }
}
