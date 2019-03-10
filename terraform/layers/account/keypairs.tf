resource "aws_secretsmanager_secret_version" "ops_public_key" {
  secret_id = "${aws_secretsmanager_secret.ops_public_key.id}"
  secret_string = "${tls_private_key.ops.public_key_openssh}"
}

resource "aws_secretsmanager_secret" "ops_public_key" {
  name = "/ssh-keys/ops.pub"
}

resource "aws_secretsmanager_secret_version" "ops_private_key" {
  secret_id = "${aws_secretsmanager_secret.ops_private_key.id}"
  secret_string = "${tls_private_key.ops.private_key_pem}"
}

resource "aws_secretsmanager_secret" "ops_private_key" {
  name = "/ssh-keys/ops"
}

#management key
resource "aws_secretsmanager_secret_version" "mgmt_public_key" {
  secret_id = "${aws_secretsmanager_secret.mgmt_public_key.id}"
  secret_string = "${tls_private_key.management.public_key_openssh}"
}

resource "aws_secretsmanager_secret" "mgmt_public_key" {
  name = "/ssh-keys/management.pub"
}

resource "aws_secretsmanager_secret_version" "mgmt_private_key" {
  secret_id = "${aws_secretsmanager_secret.mgmt_private_key.id}"
  secret_string = "${tls_private_key.management.private_key_pem}"
}

resource "aws_secretsmanager_secret" "mgmt_private_key" {
  name = "/ssh-keys/management"
}

#aws keypairs
resource "aws_key_pair" "ops" {
  key_name   = "ops"
  public_key = "${tls_private_key.ops.public_key_openssh}"
}

resource "aws_key_pair" "management" {
  key_name   = "management"
  public_key = "${tls_private_key.management.public_key_openssh}"
}


resource "tls_private_key" "ops" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
resource "tls_private_key" "management" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
