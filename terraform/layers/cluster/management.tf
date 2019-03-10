module "management" {
  source = "../../modules/management"

  environment   = "${var.environment}"
  instance_type = "t2.small"

  name = "management"

  sg_id     = "${local.sg_ids["management"]}"

  subnet_ids = [
    "${lookup(local.net["default"],"eu-west-2a")}"
  ]

  vpc_id = "${lookup(local.vpcs["default"], "id")}"

  ami_id               = "${var.management_ami}"
  instance_profile_arn = "${lookup(local.roles["ops"], "instance_profile_arn")}"
  keypair_name         = "${local.key_names["ops"]}"

  vpcs = "${local.vpcs}"
  net  = "${local.net}"
  dns  = "${local.dns}"
  s3   = "${local.s3}"

}

data "aws_secretsmanager_secret_version" "management_public_key" {
  secret_id = "/ssh-keys/management.pub"
}

data "aws_secretsmanager_secret_version" "ops_private_key" {
  secret_id = "/ssh-keys/ops"
}

resource "aws_ssm_parameter" "ops_private_key" {
  name  = "/ssh-keys/ops"
  type  = "SecureString"
  value = "${data.aws_secretsmanager_secret_version.ops_private_key.secret_string}"
}

resource "aws_ssm_parameter" "management_public_key" {
  name  = "/ssh-keys/management.pub"
  type  = "String"
  value = "${data.aws_secretsmanager_secret_version.management_public_key.secret_string}"
}