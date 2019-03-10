module "indexers_a" {
  source  = "../../modules/splunk_instance"
  role    = "indexer"
  enabled = "${var.enable_splunk_indexer}"

  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-indexer"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  availability_zone = "eu-west-2a"
  cn_name           = "${var.pki_cn_name}"

  security_groups             = ["${local.sg_ids["splunk_indexer"]}"]
  associate_public_ip_address = true

  count        = "${var.enable_splunk_indexer * var.scale_splunk_indexer["eu-west-2a"]}"
  asg_max_size = "1"                                                                            // 0 to Turn off
}

module "indexers_b" {
  source = "../../modules/splunk_instance"
  enabled = "${var.enable_splunk_indexer}"

  role                  = "indexer"
  environment           = "${var.environment}"
  ami_id                = "${var.splunk_ami}"
  keypair_name          = "${local.key_names["ops"]}"
  instance_profile_name = "${lookup(local.roles["splunk-indexer"], "instance_profile_name")}"
  splunk_admin_username = "${var.splunk_admin_username}"

  dns               = "${local.dns}"
  vpcs              = "${local.vpcs}"
  net               = "${local.net}"
  sg_ids            = "${local.sg_ids}"
  s3                = "${local.s3}"
  availability_zone = "eu-west-2b"
  cn_name           = "${var.pki_cn_name}"

  security_groups             = ["${local.sg_ids["splunk_indexer"]}"]
  associate_public_ip_address = true

  count        = "${var.enable_splunk_indexer * var.scale_splunk_indexer["eu-west-2b"]}"
  asg_max_size = "1"                                                                            //0 to Turn off
}
