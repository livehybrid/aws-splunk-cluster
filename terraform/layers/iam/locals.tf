data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "account" {}

locals {
  account_id = "${data.aws_caller_identity.current.account_id}"

  account_name = "${data.aws_iam_account_alias.account.account_alias}" //-${var.environment}

  s3 = "${data.terraform_remote_state.account.s3}"

  kms = "${data.terraform_remote_state.account.kms}"

  dns = "${data.terraform_remote_state.account.dns}"

  vpcs = "${data.terraform_remote_state.account.vpcs}"

  net = "${data.terraform_remote_state.account.net}"

  sg_ids = "${data.terraform_remote_state.account.sg_ids}"

  secrets = "${data.terraform_remote_state.account.secrets}"
}
