locals {
  kms = {
    cloudtrail = {
      arn = "${aws_kms_key.cloudtrail.arn}"
    }

    sqs-config = {
      arn = "${aws_kms_key.sqs-config.arn}"
    }

    kinesis = {
      arn = "${aws_kms_key.kinesis.arn}"
    }

    pki = {
      arn = "${aws_kms_key.pki.arn}"
    }
  }

  endpoints = {
    s3 = {
      prefix_list_id = "${aws_vpc_endpoint.ep_s3.prefix_list_id}"
    }

    kms = {
      sg_id = "${aws_security_group.ep_kms.id}"
    }

    ec2 = {
      sg_id = "${aws_security_group.ep_ec2.id}"
    }

    elb = {
      sg_id = "${aws_security_group.ep_elb.id}"
    }

    ssm = {
      sg_id = "${aws_security_group.ep_ssm.id}"
    }

    logs = {
      sg_id = "${aws_security_group.ep_logs.id}"
    }

    sns = {
      sg_id = "${aws_security_group.sns.id}"
    }

    events = {
      sg_id = "${aws_security_group.ep_events.id}"
    }

    monitoring = {
      sg_id = "${aws_security_group.ep_monitoring.id}"
    }

    sqs = {
      sg_id = "${aws_security_group.sqs.id}"
    }

    //    sts = {
    //      sg_id = "${aws_security_group.sts.id}"
    //    }
  }

  s3 = {
    cloudtrail = {
      name = "${aws_s3_bucket.cloudtrail.bucket}"
      arn  = "${aws_s3_bucket.cloudtrail.arn}"
    }

    resources = {
      name = "${aws_s3_bucket.resources.bucket}"
      arn  = "${aws_s3_bucket.resources.arn}"
    }

    ma-certs = {
      name = "${aws_s3_bucket.ma-certs.bucket}"
      arn  = "${aws_s3_bucket.ma-certs.arn}"
    }
  }

  dns = {
    private-audit = {
      zone_id = "${aws_route53_zone.private-audit.zone_id}"
      name    = "${replace(aws_route53_zone.private-audit.name,"/[.]$/", "")}"
    }

    public-audit = {
      zone_id = "${data.aws_route53_zone.public-audit.zone_id}"
      name    = "${replace(data.aws_route53_zone.public-audit.name,"/[.]$/", "")}"
    }
  }

  vpcs = {
    default = {
      id   = "${aws_vpc.default.id}"
      cidr = "${aws_vpc.default.cidr_block}"
    }
  }

  net = {
    default = {
      eu-west-2a = "${aws_subnet.default_a.id}"
      eu-west-2b = "${aws_subnet.default_b.id}"
    }
  }

  net_lists = {
    default = ["${aws_subnet.default_a.id}", "${aws_subnet.default_b.id}"]
  }

  key_names = {
    ops        = "${aws_key_pair.ops.key_name}",
    management = "${aws_key_pair.management.key_name}"
  }

  secrets = {
    ca-password = {
      arn = "${aws_secretsmanager_secret.ca-password.arn}"
      id = "${aws_secretsmanager_secret.ca-password.id}"
    }
    license = {
      arn = "${aws_secretsmanager_secret.license.arn}"
      id = "${aws_secretsmanager_secret.license.id}"
    }
    slack-webook = {
      arn = "${aws_secretsmanager_secret.alerts_slack_webhook.arn}"
      id = "${aws_secretsmanager_secret.alerts_slack_webhook.id}"
    }

  }

  sg_ids = {
    management            = "${aws_security_group.management.id}"
    splunk                = "${var.environment=="audit" ? element(concat(aws_security_group.splunk.*.id,list("")),0) : ""}"
    splunk_indexer        = "${var.enable_splunk_indexer ? element(concat(aws_security_group.splunk_indexer.*.id,list("")),0) : ""}"
    splunk_master         = "${var.enable_splunk_master ? element(concat(aws_security_group.splunk_master.*.id, list("")),0) : ""}"
    splunk_alb            = "${aws_security_group.splunk_alb.id}"
    splunk_hec_alb        = "${aws_security_group.splunk_hec_alb.id}"
    splunk_searchhead     = "${var.enable_splunk_searchhead ? element(concat(aws_security_group.splunk_searchhead.*.id, list("")),0) : ""}"
    splunk_forwarder      = "${var.enable_splunk_forwarder ? element(concat(aws_security_group.splunk_forwarder.*.id, list("")),0) : ""}"
    splunk_license        = "${var.enable_splunk_license ? element(concat(aws_security_group.splunk_license.*.id, list("")),0) : ""}"
    splunk_searchhead_alb = "${var.enable_splunk_searchhead ? element(concat(aws_security_group.splunk_searchhead_alb.*.id, list("")),0) : ""}"
    splunk_entry_alb      = "${var.enable_splunk_searchhead ? element(concat(aws_security_group.splunk_entry_alb.*.id, list("")),0) : ""}"
  }
}

output "kms" {
  value = "${local.kms}"
}

output "s3" {
  value = "${local.s3}"
}

output "dns" {
  value = "${local.dns}"
}

output "vpcs" {
  value = "${local.vpcs}"
}

output "net" {
  value = "${local.net}"
}

output "net_lists" {
  value = "${local.net_lists}"
}

output "key_names" {
  value = "${local.key_names}"
}

output "secrets" {
  value = "${local.secrets}"
}

output "sg_ids" {
  value = "${local.sg_ids}"
}

output "endpoints" {
  value = "${local.endpoints}"
}
