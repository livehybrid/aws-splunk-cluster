resource "aws_eip" "license_server" {
  vpc = true

  tags {
    Name = "license_server_eip"
    host = "license"
  }

  count = "${var.enable_splunk_license}"
}

module "license_a" {
  source = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_license}"

  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-license"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  role              = "license"
  availability_zone = "eu-west-2a"
  cn_name           = "${var.pki_cn_name}"
  splunkcloud_fwd   = "${var.splunkcloud_fwd}"
  splunk_admin_username = "${var.splunk_admin_username}"

  security_groups             = ["${local.sg_ids["splunk_license"]}"]
  associate_public_ip_address = false

  //target_group = "${aws_lb_target_group.master-api.id}"

  count        = "1"                                                                     //Should only ever be 1 master node
  asg_max_size = "${var.enable_splunk_license * var.scale_splunk_license["eu-west-2a"]}"
}

module "license_b" {
  source = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_license}"

  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-license"], "instance_profile_name")}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  role              = "license"
  availability_zone = "eu-west-2b"
  cn_name           = "${var.pki_cn_name}"
  splunkcloud_fwd   = "${var.splunkcloud_fwd}"

  security_groups             = ["${local.sg_ids["splunk_license"]}"]
  associate_public_ip_address = false

  count            = "${var.enable_splunk_license * var.scale_splunk_license["eu-west-2b"]}"                                                                     //Should only ever be 1 master node
  asg_max_size     = "${var.enable_splunk_license * var.scale_splunk_license["eu-west-2b"]}" //Offline version
  asg_desired_size = "${var.enable_splunk_license}"

  #Switched to elastic IP
  //target_group = "${aws_lb_target_group.master-api.id}"
}

resource "aws_route53_record" "license-api" {
  count = "${var.enable_splunk_license}"

  name    = "license"
  type    = "A"
  zone_id = "${lookup(local.dns["public-audit"], "zone_id")}"

  ttl     = "300"
  records = ["${aws_eip.license_server.0.public_ip}"]
}

#Cannot be locked to specific eips
data "aws_iam_policy_document" "ec2_associate_license_eip" {
  statement {
    actions = [
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
      "ec2:DescribeAddresses",
    ]

    resources = ["*"]
  }
}

#Allow license to get license
resource "aws_iam_role_policy" "ec2_associate_license_eip" {
  count = "${var.enable_splunk_license}"

  name   = "associate_eip"
  role   = "${lookup(local.roles["splunk-license"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_associate_license_eip.json}"
}

data "aws_iam_policy_document" "splunk_secret_license" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "${lookup(local.secrets["license"],"arn")}",
    ]
  }
}

#Allow license to associate elastic IP
resource "aws_iam_role_policy" "splunk_license_license" {
  count = "${var.enable_splunk_license}"

  name   = "secret_license"
  role   = "${lookup(local.roles["splunk-license"],"role_id")}"
  policy = "${data.aws_iam_policy_document.splunk_secret_license.json}"
}
