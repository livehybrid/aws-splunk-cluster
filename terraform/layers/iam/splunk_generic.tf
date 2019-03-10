//resource "aws_iam_role_policy" "splunk_generic" {
//  name   = "SplunkGeneric"
//  role   = "${aws_iam_role.splunk_generic.id}"
//  policy = "${data.aws_iam_policy_document.splunk.json}"
//}
//
//resource "aws_iam_instance_profile" "splunk_generic" {
//  name = "${aws_iam_role.splunk_generic.name}"
//  role = "${aws_iam_role.splunk_generic.name}"
//}
//#Used to send SNS alerts from Splunk
//resource "aws_iam_role_policy" "sns-security-alert_generic" {
//  name   = "sns-security-alert"
//  role   = "${aws_iam_role.splunk_generic.id}"
//  policy = "${data.aws_iam_policy_document.sns-security-alert.json}"
//}
//
//#Used to get config changes from SQS
//resource "aws_iam_role_policy" "sqs-config-changes_generic" {
//  name   = "sqs-config-changes"
//  role   = "${aws_iam_role.splunk_generic.id}"
//  policy = "${data.aws_iam_policy_document.sqs-config-changes.json}"
//}
//
//resource "aws_iam_role" "splunk_generic" {
//  name                  = "SplunkGeneric"
//  force_detach_policies = true
//  assume_role_policy    = "${data.aws_iam_policy_document.ec2_assume_role.json}"
//}
//
//resource "aws_iam_role_policy" "s3_ca_crt_access_generic" {
//  name   = "s3_ca_crt_access"
//  role   = "${aws_iam_role.splunk_generic.id}"
//  policy = "${data.aws_iam_policy_document.s3_ca_crt_access.json}"
//}
