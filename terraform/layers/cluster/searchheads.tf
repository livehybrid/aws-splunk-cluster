module "searchheads_a" {
  source = "../../modules/splunk_instance"
  role   = "searchhead"
  enabled = "${var.enable_splunk_searchhead}"

  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-sh"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  oauth_clientid = "${var.oauth_clientid}"
  oauth_clientsecret = "${var.oauth_clientsecret}"
  oauth_server = "${var.oauth_server}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  availability_zone = "eu-west-2a"
  cn_name           = "${var.pki_cn_name}"

  security_groups = [
    "${local.sg_ids["splunk_searchhead"]}"
  ]

  associate_public_ip_address = true

  //asg_max_size = "0" //Turn off
  count        = "${var.enable_splunk_searchhead * var.scale_splunk_searchhead["eu-west-2a"]}"
  target_group = "${element(concat(aws_lb_target_group.splunk_searchheads.*.arn, list("")),0)}"
}

module "searchheads_b" {
  source = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_searchhead}"

  role                  = "searchhead"
  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-sh"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  availability_zone = "eu-west-2b"
  cn_name           = "${var.pki_cn_name}"

  //asg_max_size = "0" //Turn off

  security_groups = [
    "${local.sg_ids["splunk_searchhead"]}"
  ]
  associate_public_ip_address = true
  count                       = "${var.enable_splunk_searchhead * var.scale_splunk_searchhead["eu-west-2a"]}"
  target_group                = "${element(concat(aws_lb_target_group.splunk_searchheads.*.arn, list("")),0)}"
}
