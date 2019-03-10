data "aws_caller_identity" "current" {}

data "aws_iam_account_alias" "account" {}
resource "null_resource" "nacl_construct_ssh" {
  count = "${length(var.trusted_cidrs)}"

  triggers {
    egress = false,
    protocol = "tcp",
    cidr_block = "${element(var.trusted_cidrs, count.index)}",
    from_port = 22,
    to_port = 22
  }
}

locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
  account_name = "${data.aws_iam_account_alias.account.account_alias}"
  //-${var.environment}

  base_vpc_nacl_rules = [
    {
      egress = false,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 443,
      to_port = 443
    },
    # https in
    {
      egress = false,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 8089,
      to_port = 8089
    },
    # splunkd in
    {
      egress = false,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 9997,
      to_port = 9997
    },
    # splunk fwd in
    {
      egress = false,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 1024,
      to_port = 65535
    },
    # High ports in
    {
      egress = true,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 8089,
      to_port = 8089
    },
    # Splunk out
    {
      egress = true,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 9997,
      to_port = 9997
    },
    # Splunk forwarder out (to cloud)
    {
      egress = true,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 80,
      to_port = 80
    },
    #http out - Apps/Repos

    {
      egress = true,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 22,
      to_port = 22
    },
    # SSH out - Git!
    {
      egress = true,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 443,
      to_port = 443
    },
    # https out
    {
      egress = true,
      protocol = "tcp",
      cidr_block = "0.0.0.0/0",
      from_port = 1024,
      to_port = 65535
    },
    # High ports out
  ]

  default_vpc_nacl_rules = "${concat(local.base_vpc_nacl_rules,null_resource.nacl_construct_ssh.*.triggers)}"

  s3_bucket_access = [
    "${aws_s3_bucket.ma-certs.arn}",
    "${aws_s3_bucket.ma-certs.arn}/*",
    "${aws_s3_bucket.resources.arn}",
    "${aws_s3_bucket.resources.arn}/*",
    "${aws_s3_bucket.cloudtrail.arn}",
    "${aws_s3_bucket.cloudtrail.arn}/*",
    "arn:aws:s3:::prod-eu-west-2-starport-layer-bucket/*"
  ]
  custom_s3_bucket_access = "${var.custom_s3_bucket_access}"
  combined_s3_bucket_access = [
    "${concat(local.s3_bucket_access, local.custom_s3_bucket_access) }"]

}


