############ ...OPS... ###############

data "aws_iam_policy_document" "ops" {
  statement {
    actions = [
      "acm:*",
      "autoscaling:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "config:*",
      "ds:*",
      "dynamodb:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "elasticmapreduce:*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "s3:*Bucket*",
      "s3:*Configuration",
      "secretsmanager:*",
      "ssm:*",
      "sns:*",
      "rds:*",
      "route53:*",
      "vpc:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${var.account_id}:role/Scout2",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.account_name}-terraform",
      "${lookup(local.s3["resources"], "arn")}",
    ]
  }

  # read write buckets
  statement {
    actions = [
      "${local.iam_s3_read_write_actions}",
    ]

    resources = [
      "arn:aws:s3:::${local.account_name}-terraform/*",
      "${lookup(local.s3["resources"], "arn")}",
    ]
  }
}

resource "aws_iam_role_policy" "ops" {
  name   = "${aws_iam_role.ops.name}"
  role   = "${aws_iam_role.ops.name}"
  policy = "${data.aws_iam_policy_document.ops.json}"
}

resource "aws_iam_instance_profile" "ops" {
  name = "${aws_iam_role.ops.name}"
  role = "${aws_iam_role.ops.name}"
}

resource "aws_iam_role" "ops" {
  name                  = "Ops"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}


data "aws_iam_policy_document" "bastion_route53" {

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${lookup(local.dns["public-audit"], "zone_id")}"
    ]
  }

}


resource "aws_iam_role_policy" "ops_bastion_route53" {
  name   = "${aws_iam_role.ops.name}-bastion_route53"
  role   = "${aws_iam_role.ops.name}"
  policy = "${data.aws_iam_policy_document.bastion_route53.json}"
}