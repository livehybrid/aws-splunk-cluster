resource "aws_iam_role_policy" "splunk_license" {
  name   = "splunk"
  role   = "${aws_iam_role.splunk_license.id}"
  policy = "${data.aws_iam_policy_document.splunk.json}"
}

resource "aws_iam_instance_profile" "splunk_license" {
  name = "${aws_iam_role.splunk_license.name}"
  role = "${aws_iam_role.splunk_license.name}"
}

resource "aws_iam_role" "splunk_license" {
  name                  = "SplunkLicense"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy" "s3_ca_crt_access_license" {
  name   = "s3_ca_crt_access"
  role   = "${aws_iam_role.splunk_license.id}"
  policy = "${data.aws_iam_policy_document.s3_ca_crt_access.json}"
}
