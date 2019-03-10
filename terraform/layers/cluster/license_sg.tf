#TEMPORARY RULE TO ALLOW CONFIG
//resource "aws_security_group_rule" "license_ssh_from_trusted" {
//  count        = "${var.enable_splunk_license}"
//
//  description       = "to splunk ssh"
//  from_port         = 22
//  to_port           = 22
//  protocol          = "tcp"
//  security_group_id = "${local.sg_ids["splunk_license"]}"
//  type              = "ingress"
//  cidr_blocks       = ["${var.trusted_cidrs}"]
//}

resource "aws_security_group_rule" "license_http_from_trusted" {
  count        = "${var.enable_splunk_license}"

  description       = "to splunk http"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  type              = "ingress"
  cidr_blocks       = ["${var.trusted_cidrs}"]
}

#This is needed to send on to Splunk Cloud
resource "aws_security_group_rule" "license_fwd_to_www" {
  count        = "${var.enable_splunk_license}"

  description       = "fwd to www"
  from_port         = 9997
  to_port           = 9997
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "license_from_www" {
  count        = "${var.enable_splunk_license}"

  description              = "from www"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_license"]}"
  to_port                  = 443
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]

}


resource "aws_security_group_rule" "license_8089_to_master" {
  count        = "${var.enable_splunk_license * var.enable_splunk_master}"

  description       = "to master"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  to_port           = 8089
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

resource "aws_security_group_rule" "license_8089_from_idx" {
  count        = "${var.enable_splunk_license * var.enable_splunk_indexer}"

  description       = "from indexer"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "license_8089_from_sh" {
  count        = "${var.enable_splunk_license * var.enable_splunk_searchhead}"

  description       = "from searchhead"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}
resource "aws_security_group_rule" "license_8089_from_master" {
  count        = "${var.enable_splunk_license * var.enable_splunk_master}"

  description       = "from master"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

#Required for Lambda
resource "aws_security_group_rule" "license_to_www_https" {
  count        = "${var.enable_splunk_license}"

  description       = "to www https"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_license"]}"
  to_port           = 443
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}