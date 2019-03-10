resource "aws_lb" "splunk_forwarder" {
  name     = "splunk-forwarders"
  count    = "${var.enable_splunk_forwarder}"
  internal = false

  #enable_cross_zone_load_balancing = true
  enable_deletion_protection = true

  load_balancer_type = "network"

  subnets = [
    "${values(local.net["default"])}",
  ]

  tags {
    Name        = "splunk-forwarders"
    Environment = "${var.environment}"
    source      = "terraform"
    project     = "splunk"
  }
}

#Service Endpoint for HEC and Splunk2Splunk

resource "aws_vpc_endpoint_service" "splunk_forwarder" {
  count                      = "${var.enable_splunk_forwarder}"
  acceptance_required        = false
  network_load_balancer_arns = ["${aws_lb.splunk_forwarder.arn}"]

  depends_on = ["aws_lb.splunk_forwarder"]
}

output "forwarder_service_endpoint" {
  value = "${aws_vpc_endpoint_service.splunk_forwarder.*.service_name}"
}

resource "aws_lb_listener" "splunk_forwarder" {
  count = "${var.enable_splunk_forwarder}"

  default_action {
    target_group_arn = "${aws_lb_target_group.splunk_forwarder.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.splunk_forwarder.arn}"
  protocol          = "TCP"
  port              = 443
}

resource "aws_lb_target_group" "splunk_forwarder" {
  count    = "${var.enable_splunk_forwarder}"
  port     = 9997
  protocol = "TCP"
  vpc_id   = "${lookup(local.vpcs["default"],"id")}"
  name     = "splunk-forwarders"

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }
}
