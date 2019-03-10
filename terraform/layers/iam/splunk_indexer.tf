resource "aws_iam_role_policy" "splunk_idx" {
  name   = "SplunkIndexer"
  role   = "${aws_iam_role.splunk_idx.id}"
  policy = "${data.aws_iam_policy_document.splunk.json}"
}

resource "aws_iam_instance_profile" "splunk_idx" {
  name = "${aws_iam_role.splunk_idx.name}"
  role = "${aws_iam_role.splunk_idx.name}"
}
#Used to send SNS alerts from Splunk
resource "aws_iam_role_policy" "sns-security-alert_idx" {
  name   = "sns-security-alert"
  role   = "${aws_iam_role.splunk_idx.id}"
  policy = "${data.aws_iam_policy_document.sns-security-alert.json}"
}

resource "aws_iam_role" "splunk_idx" {
  name                  = "SplunkIndexer"
  force_detach_policies = true
  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy" "s3_ca_crt_access_idx" {
  name   = "s3_ca_crt_access"
  role   = "${aws_iam_role.splunk_idx.id}"
  policy = "${data.aws_iam_policy_document.s3_ca_crt_access.json}"
}

data "aws_iam_policy_document" "volume_mount_idx" {

  statement {
    actions = [
      "ec2:DescribeVolumes"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:AttachVolume"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "volume_mount_idx" {
  name   = "volume_mount"
  role   = "${aws_iam_role.splunk_idx.id}"
  policy = "${data.aws_iam_policy_document.volume_mount_idx.json}"
}
