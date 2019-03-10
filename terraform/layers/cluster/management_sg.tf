resource "aws_security_group_rule" "management_to_www_https" {
  description       = "to www https"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 443
  type              = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "ssh_management_to_splunk_master" {
  count = "${var.enable_splunk_master}"

  description       = "to splunk master"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 22
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_master"]}"
}
resource "aws_security_group_rule" "ssh_management_to_splunk_license" {
  count = "${var.enable_splunk_license}"

  description       = "to splunk license"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 22
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_license"]}"
}

resource "aws_security_group_rule" "ssh_management_to_splunk_sh" {
  count = "${var.enable_splunk_searchhead}"

  description       = "to splunk sh"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 22
  type              = "egress"
  source_security_group_id = "${local.sg_ids["splunk_searchhead"]}"
}

resource "aws_security_group_rule" "ssh_management_to_splunk_indexers" {
  count = "${var.enable_splunk_indexer}"

  description       = "to splunk indexers"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 22
  type              = "egress"

  source_security_group_id = "${local.sg_ids["splunk_indexer"]}"
}

resource "aws_security_group_rule" "ssh_management_to_splunk_fowarders" {
  count = "${var.enable_splunk_forwarder}"

  description       = "to splunk forwarders"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 22
  type              = "egress"

  source_security_group_id = "${local.sg_ids["splunk_forwarder"]}"
}

resource "aws_security_group_rule" "ssh_management_from_trusted" {
  description       = "from trusted ip"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 22
  type              = "ingress"

  cidr_blocks = [
    "${var.trusted_cidrs}",
  ]
}

resource "aws_security_group_rule" "ssh_searchhead_from_manangement" {
  count = "${var.enable_splunk_searchhead}"

  description              = "from Management"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_searchhead"]}"
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["management"]}"
}

resource "aws_security_group_rule" "ssh_license_from_manangement" {
  count = "${var.enable_splunk_license}"

  description              = "from management"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_license"]}"
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["management"]}"
}

resource "aws_security_group_rule" "ssh_indexers_from_manangement" {
  count = "${var.enable_splunk_indexer}"

  description              = "from Management"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_indexer"]}"
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["management"]}"
}

resource "aws_security_group_rule" "ssh_master_from_manangement" {
  count = "${var.enable_splunk_master}"

  description              = "from Management"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_master"]}"
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["management"]}"
}

resource "aws_security_group_rule" "ssh_forwarder_from_manangement" {
  count = "${var.enable_splunk_forwarder}"

  description              = "from Management"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["splunk_forwarder"]}"
  type                     = "ingress"
  source_security_group_id = "${local.sg_ids["management"]}"
}

resource "aws_security_group_rule" "management_to_s3" {
  description       = "to s3"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${local.sg_ids["management"]}"
  to_port           = 443
  type              = "egress"

  prefix_list_ids = [
    "${lookup(local.endpoints["s3"], "prefix_list_id")}",
  ]
}

//resource "aws_security_group_rule" "management_to_dynamodb" {
//  description       = "to dynamodb"
//  from_port         = 443
//  protocol          = "tcp"
//  security_group_id = "${local.sg_ids["management"]}"
//  to_port           = 443
//  type              = "egress"
//
//  prefix_list_ids = [
//    "${lookup(local.endpoints["dynamodb"], "prefix_list_id")}",
//  ]
//}


resource "aws_security_group_rule" "management_to_kms" {
  description              = "to kms"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["management"]}"
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = "${lookup(local.endpoints["kms"], "sg_id")}"
}


resource "aws_security_group_rule" "management_to_ec2" {
  description              = "to ec2"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["management"]}"
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = "${lookup(local.endpoints["ec2"], "sg_id")}"
}

resource "aws_security_group_rule" "management_to_elb" {
  description              = "to elb"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["management"]}"
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = "${lookup(local.endpoints["elb"], "sg_id")}"
}


resource "aws_security_group_rule" "management_to_logs" {
  description              = "to logs"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["management"]}"
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = "${lookup(local.endpoints["logs"], "sg_id")}"
}


resource "aws_security_group_rule" "management_to_ssm" {
  description              = "to ssm"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${local.sg_ids["management"]}"
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = "${lookup(local.endpoints["ssm"], "sg_id")}"
}


//resource "aws_security_group_rule" "management_to_sns" {
//  description              = "to sns"
//  from_port                = 443
//  protocol                 = "tcp"
//  security_group_id        = "${local.sg_ids["management"]}"
//  to_port                  = 443
//  type                     = "egress"
//  source_security_group_id = "${lookup(local.endpoints["sns"], "sg_id")}"
//}
//

//resource "aws_security_group_rule" "management_to_sqs" {
//  description              = "to sns"
//  from_port                = 443
//  protocol                 = "tcp"
//  security_group_id        = "${local.sg_ids["management"]}"
//  to_port                  = 443
//  type                     = "egress"
//  source_security_group_id = "${lookup(local.endpoints["sqs"], "sg_id")}"
//}
//
//
//resource "aws_security_group_rule" "management_to_secretsmanager" {
//  description              = "to secretsmanager"
//  from_port                = 443
//  protocol                 = "tcp"
//  security_group_id        = "${local.sg_ids["management"]}"
//  to_port                  = 443
//  type                     = "egress"
//  source_security_group_id = "${lookup(local.endpoints["secretsmanager"], "sg_id")}"
//}


//resource "aws_security_group_rule" "management_to_config" {
//  description              = "to config"
//  from_port                = 443
//  protocol                 = "tcp"
//  security_group_id        = "${local.sg_ids["management"]}"
//  to_port                  = 443
//  type                     = "egress"
//  source_security_group_id = "${lookup(local.endpoints["config"], "sg_id")}"
//}
//

//resource "aws_security_group_rule" "management_to_events" {
//  description              = "to events"
//  from_port                = 443
//  protocol                 = "tcp"
//  security_group_id        = "${local.sg_ids["management"]}"
//  to_port                  = 443
//  type                     = "egress"
//  source_security_group_id = "${lookup(local.endpoints["events"], "sg_id")}"
//}
//

