resource "aws_iam_role_policy" "splunk_forwarder" {
  name   = "splunk"
  role   = "${aws_iam_role.splunk_forwarder.id}"
  policy = "${data.aws_iam_policy_document.splunk.json}"
}

resource "aws_iam_instance_profile" "splunk_forwarder" {
  name = "${aws_iam_role.splunk_forwarder.name}"
  role = "${aws_iam_role.splunk_forwarder.name}"
}

resource "aws_iam_role" "splunk_forwarder" {
  name                  = "SplunkForwarder"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy" "s3_ca_crt_access_fwd" {
  name   = "s3_ca_crt_access"
  role   = "${aws_iam_role.splunk_forwarder.id}"
  policy = "${data.aws_iam_policy_document.s3_ca_crt_access.json}"
}
