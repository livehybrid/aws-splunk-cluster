resource "aws_route53_record" "splunk_forwarder_hec" {
  count   = "${var.enable_splunk_forwarder}"
  name    = "hec"
  type    = "A"
  zone_id = "${lookup(local.dns["public-audit"], "zone_id")}"

  alias {
    name                   = "${aws_lb.splunk_forwarder_hec.0.dns_name}"
    zone_id                = "${aws_lb.splunk_forwarder_hec.0.zone_id}"
    evaluate_target_health = true
  }
}
