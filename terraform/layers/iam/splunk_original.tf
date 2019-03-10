#Used to send SNS alerts from Splunk
resource "aws_iam_role_policy" "sns-security-alert" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name   = "sns-security-alert"
  role   = "${aws_iam_role.splunk.id}"
  policy = "${data.aws_iam_policy_document.sns-security-alert.json}"
}

#Used to get config changes from SQS
resource "aws_iam_role_policy" "sqs-config-changes" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name   = "sqs-config-changes"
  role   = "${aws_iam_role.splunk.id}"
  policy = "${data.aws_iam_policy_document.sqs-config-changes.json}"
}

resource "aws_iam_role_policy" "splunk" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name   = "splunk"
  role   = "${aws_iam_role.splunk.id}"
  policy = "${data.aws_iam_policy_document.splunk.json}"
}

resource "aws_iam_instance_profile" "splunk" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name = "${aws_iam_role.splunk.name}"
  role = "${aws_iam_role.splunk.name}"
}

resource "aws_iam_role" "splunk" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name                  = "Splunk"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy" "s3_ca_crt_access_splunk" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name   = "s3_ca_crt_access"
  role   = "${aws_iam_role.splunk.id}"
  policy = "${data.aws_iam_policy_document.s3_ca_crt_access.json}"
}