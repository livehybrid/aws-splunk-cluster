resource "aws_security_group_rule" "splunk_from_splunk_searchhead_alb" {
  count                    = "${var.enable_splunk_searchhead}"
  description              = "from splunk_searchhead_alb"
  from_port                = 8443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  to_port                  = 8443
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead_alb"]}"
}

resource "aws_security_group_rule" "splunk_alb_to_splunk" {
  count                    = "${var.enable_splunk_searchhead}"
  description              = "to splunk http"
  from_port                = 8443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead_alb"]}"
  to_port                  = 8443
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}

resource "aws_security_group_rule" "searchhead_kvstore_replication" {
  count             = "${var.enable_splunk_searchhead}"
  description       = "KV Store Replication"
  self              = true
  from_port         = 8191
  to_port           = 8191
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_searchhead"]}"
  type              = "ingress"
}

resource "aws_security_group_rule" "searchhead_search_replication" {
  count             = "${var.enable_splunk_searchhead}"
  description       = "Search Replication"
  self              = true
  from_port         = 8181
  to_port           = 8181
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_searchhead"]}"
  type              = "ingress"
}

#TEMPORARY RULE TO ALLOW CONFIG
//resource "aws_security_group_rule" "searchhead_ssh_from_trusted" {
//  count        = "${var.enable_splunk_searchhead}"
//  description       = "to splunk ssh"
//  from_port         = 22
//  to_port           = 22
//  protocol          = "tcp"
//  security_group_id = "${local.sg_ids["splunk_searchhead"]}"
//  type              = "ingress"
//  cidr_blocks       = ["${var.trusted_cidrs}"]
//}

resource "aws_security_group_rule" "searchhead_alb_http_from_trusted" {
  count             = "${var.enable_splunk_searchhead}"
  description       = "to splunk http"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_searchhead_alb"]}"
  type              = "ingress"
  cidr_blocks       = ["${var.trusted_cidrs}"]
}

resource "aws_security_group_rule" "sh_to_9997_indexers" {
  count                    = "${var.enable_splunk_searchhead * var.enable_splunk_indexer}"
  description              = "to indexers"
  from_port                = 9997
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  to_port                  = 9997
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "sh_to_8089_indexers" {
  count                    = "${var.enable_splunk_searchhead * var.enable_splunk_indexer}"
  description              = "to indexers"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "sh_to_8089_master" {
  count                    = "${var.enable_splunk_searchhead * var.enable_splunk_master}"
  description              = "to master"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

resource "aws_security_group_rule" "sh_to_8089_license" {
  count                    = "${var.enable_splunk_searchhead * var.enable_splunk_license}"
  description              = "to license"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_license"]}"
}

resource "aws_security_group_rule" "sh_to_8089_self" {
  count             = "${var.enable_splunk_searchhead}"
  description       = "to self"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_searchhead"]}"
  to_port           = 8089
  type              = "egress"
  self              = true
}

resource "aws_security_group_rule" "sh_from_8089_self" {
  count             = "${var.enable_splunk_searchhead}"
  description       = "from self"
  from_port         = 8089
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_searchhead"]}"
  to_port           = 8089
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "sh_from_8089_master" {
  count                    = "${var.enable_splunk_searchhead * var.enable_splunk_master}"
  description              = "from master"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  to_port                  = 8089
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

#Required for Lambda
resource "aws_security_group_rule" "sh_to_www_https" {
  count             = "${var.enable_splunk_searchhead}"
  description       = "to www https"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_searchhead"]}"
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
