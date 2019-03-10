data "aws_iam_policy_document" "vpce_s3_policy" {
  statement {
    sid     = "AllowAccessToKnownS3"
    actions = ["s3:*"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    resources = ["${local.combined_s3_bucket_access}"]
  }

  statement {
    sid = "AllowListingOfMyBuckets"
    actions = ["s3:ListAllMyBuckets"]
    principals {
      identifiers = ["*"]
      type = "*"
    }
    resources = ["*"]
  }
}

resource "aws_vpc_endpoint" "ep_s3" {
  vpc_id = "${aws_vpc.default.id}"
  policy = "${data.aws_iam_policy_document.vpce_s3_policy.json}"
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3_default_rt" {
  vpc_endpoint_id = "${aws_vpc_endpoint.ep_s3.id}"
  route_table_id  = "${aws_default_route_table.default.id}"
}

resource "aws_security_group" "ep_kms" {
  name        = "kms-vpc-endpoints-sg"
  description = "kms-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "kms-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_kms" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_kms.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "ep_ec2" {
  name        = "ec2-vpc-endpoints-sg"
  description = "ec2-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "ec2-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_ec2" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_ec2.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "ep_elb" {
  name        = "elb-vpc-endpoints-sg"
  description = "elb-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "elb-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_elb" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.elasticloadbalancing"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_elb.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "ep_ssm" {
  name        = "ssm-vpc-endpoints-sg"
  description = "ssm-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "ssm-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_ssm" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_ssm.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "ep_logs" {
  name        = "logs-vpc-endpoints-sg"
  description = "logs-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "logs-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_logs" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_logs.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "ep_events" {
  name        = "events-vpc-endpoints-sg"
  description = "events-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "events-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_events" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.events"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_events.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "ep_monitoring" {
  name        = "monitoring-vpc-endpoints-sg"
  description = "monitoring-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "monitoring-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "ep_monitoring" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.monitoring"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ep_monitoring.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "sns" {
  name        = "sns-vpc-endpoints-sg"
  description = "sns-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "sns-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.sns"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"  ]

  security_group_ids = [
    "${aws_security_group.sns.id}",
  ]

  private_dns_enabled = true
}

resource "aws_security_group" "sqs" {
  name        = "sqs-vpc-endpoints-sg"
  description = "sqs-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "sqs-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}
resource "aws_security_group" "ecr" {
  name        = "ecr-vpc-endpoints-sg"
  description = "ecr-vpc-endpoints-sg"

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "ecr-vpc-endpoints-sg"
    source  = "terraform"
    project = "splunk"
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "${var.default_vpc_cidr}",
    ]
  }
}

resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.sqs.id}",
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id            = "${aws_vpc.default.id}"
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    "${data.aws_subnet_ids.all.ids}"
  ]

  security_group_ids = [
    "${aws_security_group.ecr.id}",
  ]

  private_dns_enabled = true
}


//resource "aws_security_group" "sts" {
//  name        = "sts-vpc-endpoints-sg"
//  description = "sts-vpc-endpoints-sg"
//
//  vpc_id = "${aws_vpc.default.id}"
//
//  tags {
//    Name    = "sts-vpc-endpoints-sg"
//    source  = "terraform"
//    project = "splunk"
//  }
//
//  ingress {
//    protocol  = "tcp"
//    from_port = 443
//    to_port   = 443
//
//    cidr_blocks = [
//      "${var.default_vpc_cidr}",
//    ]
//  }
//}
//
//resource "aws_vpc_endpoint" "sts" {
//  vpc_id            = "${aws_vpc.default.id}"
//  service_name      = "com.amazonaws.${var.region}.sts"
//  vpc_endpoint_type = "Interface"
//
//  subnet_ids = [
//    "${data.aws_subnet_ids.all.ids}"
//  ]
//
//  security_group_ids = [
//    "${aws_security_group.sts.id}",
//  ]
//
//  private_dns_enabled = true
//}
