data "aws_cloudtrail_service_account" "main" {}

module "s3_policy_cloudtrail" {
  source           = "../../modules/s3_bucket_policy"
  bucket_name      = "${local.account_name}-cloudtrail"
  encrypted_bucket = false #Cannot force due to AWS Config not supporting KMS
}

data "aws_iam_policy_document" "s3_cloudtrail_parent" {
  source_json = "${module.s3_policy_cloudtrail.json}"

  statement {
    principals {
      identifiers = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
      type        = "Service"
    }

    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.account_name}-cloudtrail/*"]
  }

  statement {
    principals {
      identifiers = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
      type        = "Service"
    }

    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.account_name}-cloudtrail"]
  }
}
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = "${aws_s3_bucket.cloudtrail.id}"

  block_public_acls   = true
  block_public_policy = true
}
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${local.account_name}-cloudtrail"
  acl    = "private"
  region = "${var.region}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cloudtrail.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  policy = "${data.aws_iam_policy_document.s3_cloudtrail_parent.json}"

  tags {
    project     = "core"
    Name        = "${local.account_name}-cloudtrail"
    Environment = "${var.environment}"
  }
}

module "s3_policy_resources" {
  source           = "../../modules/s3_bucket_policy"
  bucket_name      = "${local.account_name}-resources"
  encrypted_bucket = false
}
resource "aws_s3_bucket_public_access_block" "resources" {
  bucket = "${aws_s3_bucket.resources.id}"

  block_public_acls   = true
  block_public_policy = true
}
resource "aws_s3_bucket" "resources" {
  bucket = "${local.account_name}-resources"
  acl    = "private"
  region = "${var.region}"

  tags {
    project     = "core"
    Name        = "${local.account_name}-resources"
    Environment = "${var.environment}"
  }
  policy = "${module.s3_policy_resources.json}"
}

module "s3_policy_ma-certs" {
  source           = "../../modules/s3_bucket_policy"
  bucket_name      = "${local.account_name}-ma-certs"
  encrypted_bucket = true
  required_kms_arn = "${aws_kms_key.pki.arn}"
  encryption_type = "aws:kms"
}
resource "aws_s3_bucket_public_access_block" "ma-certs" {
  bucket = "${aws_s3_bucket.ma-certs.id}"

  block_public_acls   = true
  block_public_policy = true
}
resource "aws_s3_bucket" "ma-certs" {
  bucket = "${local.account_name}-ma-certs"
  acl    = "private"
  region = "${var.region}"
  versioning {
    enabled = true
  }

  tags {
    project     = "core"
    Name        = "${local.account_name}-ma-certs"
    Environment = "${var.environment}"
  }
  policy = "${module.s3_policy_ma-certs.json}"

}


module "s3_policy_terraform" {
  source           = "../../modules/s3_bucket_policy"
  bucket_name      = "${data.aws_iam_account_alias.account.account_alias}-terraform"
  encrypted_bucket = true
}
resource "aws_s3_bucket_policy" "s3_terraform_policy" {

  bucket = "${data.aws_iam_account_alias.account.account_alias}-terraform"
  policy = "${module.s3_policy_terraform.json}"
}
resource "aws_s3_account_public_access_block" "block" {
  block_public_acls   = true
  block_public_policy = true
}