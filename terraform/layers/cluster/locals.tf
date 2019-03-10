data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "account" {}


locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
  account_name = "${data.aws_iam_account_alias.account.account_alias}" //-${var.environment}

  s3 = "${data.terraform_remote_state.account.s3}"

  secrets = "${data.terraform_remote_state.account.secrets}"

  kms = "${data.terraform_remote_state.account.kms}"

  key_names = "${data.terraform_remote_state.account.key_names}"

  endpoints = "${data.terraform_remote_state.account.endpoints}"

  dns = "${data.terraform_remote_state.account.dns}"

  vpcs = "${data.terraform_remote_state.account.vpcs}"

  net       = "${data.terraform_remote_state.account.net}"
  net_lists = "${data.terraform_remote_state.account.net_lists}"

  roles = "${data.terraform_remote_state.iam.roles}"

  sg_ids = "${data.terraform_remote_state.account.sg_ids}"

  cloudtrail_bucket = "${lookup(local.s3["cloudtrail"], "name")}"

  cloudtrail_metric_name_space = "CloudTrailMetrics"
}
