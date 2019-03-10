#TEMPORARY RULE TO ALLOW CONFIG
//resource "aws_security_group_rule" "master_ssh_from_trusted" {
//  description       = "to splunk ssh"
//  from_port         = 22
//  to_port           = 22
//  protocol          = "tcp"
//  security_group_id = "${local.sg_ids["splunk_master"]}"
//  type              = "ingress"
//  cidr_blocks       = ["${var.trusted_cidrs}"]
//}

resource "aws_security_group_rule" "master_http_from_trusted" {
  count        = "${var.enable_splunk_master}"

  description       = "to splunk http"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  type              = "ingress"
  cidr_blocks       = ["${var.trusted_cidrs}"]
}

resource "aws_security_group_rule" "master_to_9997_indexers" {
  count        = "${var.enable_splunk_master * var.enable_splunk_indexer}"
  description              = "to indexers"
  from_port                = 9997
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_master"]}"
  to_port                  = 9997
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}


//EGRESS
resource "aws_security_group_rule" "master_8089_from_indexers" {
  count        = "${var.enable_splunk_master * var.enable_splunk_indexer}"
  description       = "to indexers"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "master_8089_from_sh" {
  count        = "${var.enable_splunk_master * var.enable_splunk_searchhead}"
  description       = "to searchhead"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}

resource "aws_security_group_rule" "master_8089_from_license" {
  count        = "${var.enable_splunk_master * var.enable_splunk_license}"
  description       = "to license"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_license"]}"
}

//resource "aws_security_group_rule" "master_8089_from_forwarder" {
//  count        = "${var.enable_splunk_master}"
//  description       = "to forwarder"
//  from_port         = 8089
//  protocol          = "tcp"
//  security_group_id = "${local.sg_ids["splunk_master"]}"
//  to_port           = 8089
//  type              = "egress"
//  source_security_group_id = "${local.sg_ids["splunk_forwarder"]}"
//}


resource "aws_security_group_rule" "master_to_8089_self" {
  count        = "${var.enable_splunk_master}"
  description       = "to self"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "egress"
  self              = true
}

//INGRESS
resource "aws_security_group_rule" "master_from_8089_indexers" {
  count        = "${var.enable_splunk_master * var.enable_splunk_indexer}"
  description       = "from indexers"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "master_from_8089_sh" {
  count        = "${var.enable_splunk_master * var.enable_splunk_searchhead}"
  description       = "from searchhead"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}

#for deployment server
resource "aws_security_group_rule" "master_from_8089_license" {
  count        = "${var.enable_splunk_master * var.enable_splunk_license}"
  description       = "from license"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_license"]}"
}

resource "aws_security_group_rule" "master_from_8089_forwarder" {
  count        = "${var.enable_splunk_master * var.enable_splunk_forwarder}"
  description       = "from forwarder"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_forwarder"]}"
}



resource "aws_security_group_rule" "master_from_8089_self" {
  count        = "${var.enable_splunk_master}"
  description       = "from self"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 8089
  type              = "ingress"
  self              = true
}
#Required for Lambda
resource "aws_security_group_rule" "master_to_www_https" {
  count        = "${var.enable_splunk_master}"
  description       = "to www https"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 443
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

#Required for GIT SSH outbound
resource "aws_security_group_rule" "master_to_ssh_www" {
  count        = "${var.enable_splunk_master}"
  description       = "to ssh (git)"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_master"]}"
  to_port           = 22
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}
//
//resource "aws_security_group_rule" "master_to_8089_sh" {
//  count        = "${var.enable_splunk_master}"
//  description       = "to search heads"
//  from_port         = 8089
//  protocol          = "tcp"
//  security_group_id = "${local.sg_ids["splunk_master"]}"
//  to_port           = 8089
//  type              = "egress"
//  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
//}