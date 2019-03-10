resource "aws_security_group_rule" "9997_splunk_from_self" {
  count             = "${var.enable_splunk_indexer}"
  description       = "from self"
  self              = true
  from_port         = 9997
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_indexer"]}"
  to_port           = 9997
  type              = "ingress"
}

resource "aws_security_group_rule" "9887_splunk_from_self" {
  count             = "${var.enable_splunk_indexer}"
  description       = "from self"
  self              = true
  from_port         = 9887
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_indexer"]}"
  to_port           = 9887
  type              = "ingress"
}

resource "aws_security_group_rule" "9887_splunk_to_self" {
  count             = "${var.enable_splunk_indexer}"
  description       = "to self"
  self              = true
  from_port         = 9887
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_indexer"]}"
  to_port           = 9887
  type              = "egress"
}

resource "aws_security_group_rule" "8089_indexers_from_sh" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_searchhead}"
  description              = "from search head"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 8089
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}

resource "aws_security_group_rule" "8089_indexers_from_master" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_master}"
  description              = "from master"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 8089
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

resource "aws_security_group_rule" "9997_indexers_from_sh" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_searchhead}"
  description              = "from search head"
  from_port                = 9997
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 9997
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}

resource "aws_security_group_rule" "9997_indexers_from_master" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_master}"
  description              = "from master"
  from_port                = 9997
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 9997
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

resource "aws_security_group_rule" "9997_indexers_from_fwd" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_forwarder}"
  description              = "from forwarder"
  from_port                = 9997
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 9997
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["splunk_forwarder"]}"
}

resource "aws_security_group_rule" "splunk_hec_alb_to_splunk" {
  count                    = "${var.enable_splunk_indexer}"
  description              = "to splunk"
  from_port                = 8088
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_hec_alb"]}"
  to_port                  = 8088
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "8080_to_self" {
  count                    = "${var.enable_splunk_indexer}"
  description              = "to self"
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_hec_alb"]}"
  to_port                  = 8080
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "indexers_to_8089_license" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_license}"
  description              = "to license"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_license"]}"
}

resource "aws_security_group_rule" "indexers_to_8089_master" {
  count                    = "${var.enable_splunk_indexer * var.enable_splunk_master}"
  description              = "to master"
  from_port                = 8089
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  to_port                  = 8089
  type                     = "egress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}

#Required for Lambda
resource "aws_security_group_rule" "indexers_to_www_https" {
  count             = "${var.enable_splunk_indexer}"
  description       = "to www https"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["splunk_indexer"]}"
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
