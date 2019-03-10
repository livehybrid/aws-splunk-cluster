resource "aws_iam_role_policy" "splunk_master" {
  name   = "splunk"
  role   = "${aws_iam_role.splunk_master.id}"
  policy = "${data.aws_iam_policy_document.splunk.json}"
}

resource "aws_iam_instance_profile" "splunk_master" {
  name = "${aws_iam_role.splunk_master.name}"
  role = "${aws_iam_role.splunk_master.name}"
}
//#Used to send SNS alerts from Splunk
//resource "aws_iam_role_policy" "sns-security-alert_master" {
//  name   = "sns-security-alert"
//  role   = "${aws_iam_role.splunk_master.id}"
//  policy = "${data.aws_iam_policy_document.sns-security-alert.json}"
//}

//#Used to get config changes from SQS
//resource "aws_iam_role_policy" "sqs-config-changes_master" {
//  name   = "sqs-config-changes"
//  role   = "${aws_iam_role.splunk_master.id}"
//  policy = "${data.aws_iam_policy_document.sqs-config-changes.json}"
//}

resource "aws_iam_role" "splunk_master" {
  name                  = "SplunkMaster"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy" "s3_ca_crt_access_master" {
  name   = "s3_ca_crt_access"
  role   = "${aws_iam_role.splunk_master.id}"
  policy = "${data.aws_iam_policy_document.s3_ca_crt_access.json}"
}

data "aws_iam_policy_document" "public_route53_master" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${lookup(local.dns["public-audit"], "zone_id")}"
    ]
  }
}

resource "aws_iam_role_policy" "public_route53_master" {
  name   = "public_route53"
  role   = "${aws_iam_role.splunk_master.id}"
  policy = "${data.aws_iam_policy_document.public_route53_master.json}"
}

data "aws_iam_policy_document" "private_route53_master" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${lookup(local.dns["private-audit"], "zone_id")}"
    ]
  }
}
resource "aws_iam_role_policy" "private_route53_master" {
  name   = "private_route53"
  role   = "${aws_iam_role.splunk_master.id}"
  policy = "${data.aws_iam_policy_document.private_route53_master.json}"
}

data "aws_iam_policy_document" "app_secrets_master" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:/splunk/apps/*",
      "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:/git/login*"
    ]
  }
}
resource "aws_iam_role_policy" "app_secrets_master" {
  name   = "master_secrets"
  role   = "${aws_iam_role.splunk_master.id}"
  policy = "${data.aws_iam_policy_document.app_secrets_master.json}"
}

