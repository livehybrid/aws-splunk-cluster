resource "aws_security_group_rule" "external_to_hecalb_443" {
  count                    = "${var.enable_splunk_forwarder}"
  description              = "to forwarder"
  from_port                = 443
  to_port                  = 443
  security_group_id        = "${local.sg_ids["splunk_hec_alb"]}"
  protocol                 = "tcp"
  type                     = "ingress"
  cidr_blocks              = ["${var.trusted_cidrs}"]
}

resource "aws_security_group_rule" "splunk_fwd_splunk_alb_to_fwd" {
  count                    = "${var.enable_splunk_forwarder}"
  description              = "to forwarder"
  from_port                = 8088
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_hec_alb"]}"
  to_port                  = 8088
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_forwarder"]}"
}


resource "aws_security_group_rule" "splunk_fwd_to_idx_9997" {
  count                    = "${var.enable_splunk_forwarder * var.enable_splunk_indexer}"
  description              = "to indexers"
  from_port                = 9997
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
  to_port                  = 9998
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "forwarder_to_8089_license" {
  count                    = "${var.enable_splunk_forwarder * var.enable_splunk_license}"
  description              = "to license"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_license"]}"
}

resource "aws_security_group_rule" "forwarder_to_8089_master" {
  count                    = "${var.enable_splunk_forwarder * var.enable_splunk_master}"
  description              = "to master"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

resource "aws_security_group_rule" "forwarder_to_ec2_endpoint" {
  count                    = "${var.enable_splunk_forwarder}"
  description              = "to ec2 endpoint"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
  type                     = "egress"
  source_security_group_id = "${lookup(local.endpoints["ec2"],"sg_id")}"
}

#needed to get config from S3
resource "aws_security_group_rule" "forwarder_to_s3_endpoint" {
  count             = "${var.enable_splunk_forwarder}"
  description       = "to s3 endpoint"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_forwarder"]}"
  type              = "egress"
  prefix_list_ids   = ["${lookup(local.endpoints["s3"],"prefix_list_id")}"]
}

#needed to get to lambda
resource "aws_security_group_rule" "forwarder_to_www_https" {
  count             = "${var.enable_splunk_forwarder}"
  description       = "to www https"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_forwarder"]}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#Uncomment if running AWS TA app on forwarder!
//resource "aws_security_group_rule" "forwarder_to_sqs_endpoint" {
//  description              = "to sqs endpoint"
//  from_port                = 443
//  to_port                  = 443
//  protocol                 = "tcp"
//  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
//  type                     = "egress"
//  //prefix_list_ids = ["${lookup(local.endpoints["sqs"],"prefix_list_id")}"]
//  source_security_group_id = "${lookup(local.endpoints["sqs"],"sg_id")}"
//}

