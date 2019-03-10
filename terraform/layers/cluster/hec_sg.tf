resource "aws_security_group_rule" "splunkhec_from_splunkhec_alb" {
  count                    =  "${var.enable_splunk_forwarder * var.enable_splunk_indexer}"
  description              = "from splunk_alb"
  from_port                = 8088
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 8088
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_hec_alb"]}"
}

resource "aws_security_group_rule" "splunkhec_alb_to_splunk" {
  count                    =  "${var.enable_splunk_forwarder}"
  description              = "to splunk hec"
  from_port                = 8088
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
  to_port                  = 8088
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_hec_alb"]}"
}
