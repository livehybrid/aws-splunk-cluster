module "master_a" {
  source  = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_master}"

  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-master"], "instance_profile_name")}"
  apps_git_repo         = "${var.apps_git_repo}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  role              = "master"
  availability_zone = "eu-west-2a"
  cn_name           = "${var.pki_cn_name}"
  splunkcloud_fwd   = "${var.splunkcloud_fwd}"

  security_groups             = ["${local.sg_ids["splunk_master"]}"]
  associate_public_ip_address = true                                 #Required for Lambda

  //target_group = "${aws_lb_target_group.master-api.id}"

  count        = "1"                                                                   //Should only ever be 1 master node
  asg_max_size = "${var.enable_splunk_master * var.scale_splunk_master["eu-west-2a"]}"
}

module "master_b" {
  source                 = "../../modules/splunk_instance"
  enabled                = "${var.enable_splunk_master}"
  enable_splunk_indexers = "${var.enable_splunk_indexer}"

  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-master"], "instance_profile_name")}"
  apps_git_repo         = "${var.apps_git_repo}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  role              = "master"
  availability_zone = "eu-west-2b"
  cn_name           = "${var.pki_cn_name}"
  splunkcloud_fwd   = "${var.splunkcloud_fwd}"

  security_groups             = ["${local.sg_ids["splunk_master"]}"]
  associate_public_ip_address = true                                 #Required for Lambda

  count            = "1"                                                                   //Should only ever be 1 master node
  asg_max_size     = "${var.enable_splunk_master * var.scale_splunk_master["eu-west-2b"]}" //Offline version
  asg_desired_size = "${var.enable_splunk_master * var.scale_splunk_master["eu-west-2b"]}" //Offline version

  #Switched to elastic IP
  //target_group = "${aws_lb_target_group.master-api.id}"
}
