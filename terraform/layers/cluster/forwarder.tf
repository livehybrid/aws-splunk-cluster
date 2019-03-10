module "forwarder_a" {
  source = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_forwarder}"
  enable_splunk_indexers = "${var.enable_splunk_indexer}"

  role                  = "heavy-forwarder"
  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"                                                   #This can be changed for a HF AMI?
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-forwarder"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  availability_zone = "eu-west-2a"
  cn_name           = "${var.pki_cn_name}"

  security_groups             = ["${local.sg_ids["splunk_forwarder"]}"]
  associate_public_ip_address = true

  count        = "${var.enable_splunk_forwarder * var.scale_splunk_forwarder["eu-west-2a"]}" //Where scale_splunk_forwarder is the number of desired forwarders
  asg_max_size = "1"                                                                         // 0 to Turn off
  target_group = "${join(",", list(element(concat(aws_lb_target_group.splunk_forwarder.*.arn, list("")),0),
                  element(concat(aws_lb_target_group.splunk_forwarder_hec.*.arn, list("")),0)))}"
}

module "forwarder_b" {
  source = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_forwarder}"
  enable_splunk_indexers = "${var.enable_splunk_indexer}"

  role                  = "heavy-forwarder"
  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-forwarder"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  availability_zone = "eu-west-2b"
  cn_name           = "${var.pki_cn_name}"

  security_groups             = ["${local.sg_ids["splunk_forwarder"]}"]
  associate_public_ip_address = true

  count        = "${var.enable_splunk_forwarder * var.scale_splunk_forwarder["eu-west-2b"]}"
  asg_max_size = "1"                                                                         //0 to Turn off
  target_group = "${join(",", list(element(concat(aws_lb_target_group.splunk_forwarder.*.arn, list("")),0),
                  element(concat(aws_lb_target_group.splunk_forwarder_hec.*.arn, list("")),0)))}"
}
