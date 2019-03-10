//
//resource "aws_config_config_rule" "encrypted_volumes" {
//  name = "encrypted_volumes"
//
//  source {
//    owner             = "AWS"
//    source_identifier = "ENCRYPTED_VOLUMES"
//  }
//
//}
//
//resource "aws_config_config_rule" "incoming_ssh_disabled" {
//  name = "incoming_ssh_disabled"
//
//  source {
//    owner             = "AWS"
//    source_identifier = "INCOMING_SSH_DISABLED"
//  }
//
//}
//
//// see https://docs.aws.amazon.com/config/latest/developerguide/cloudtrail-enabled.html
//resource "aws_config_config_rule" "cloud_trail_enabled" {
//  name = "cloud_trail_enabled"
//
//  source {
//    owner             = "AWS"
//    source_identifier = "CLOUD_TRAIL_ENABLED"
//  }
//
//  input_parameters = <<EOF
//{
//  "s3BucketName": "${local.cloudtrail_bucket}"
//}
//EOF
//
//}
//
//
////see https://docs.aws.amazon.com/config/latest/developerguide/iam-password-policy.html
//resource "aws_config_config_rule" "iam_password_policy" {
//  name = "iam_password_policy"
//
//  source {
//    owner             = "AWS"
//    source_identifier = "IAM_PASSWORD_POLICY"
//  }
//
//  input_parameters = <<EOF
//{
//  "RequireUppercaseCharacters" : "true",
//  "RequireLowercaseCharacters" : "true",
//  "RequireSymbols" : "true",
//  "RequireNumbers" : "true",
//  "MinimumPasswordLength" : "16",
//  "PasswordReusePrevention" : "12",
//  "MaxPasswordAge" : "7"
//}
//EOF
//
//}
//
//
//
//resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
//  name = "s3_bucket_public_read_prohibited"
//
//  source {
//    owner             = "AWS"
//    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
//  }
//
//#  depends_on = ["aws_config_configuration_recorder.default"]
//}
//
//resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
//  name = "s3_bucket_public_write_prohibited"
//
//  source {
//    owner             = "AWS"
//    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
//  }
//
//#  depends_on = ["aws_config_configuration_recorder.default"]
//}
