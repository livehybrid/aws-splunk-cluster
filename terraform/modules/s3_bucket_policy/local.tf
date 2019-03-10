locals {
  disallowed_encryption = "${var.encryption_type=="AES256" ? "aws:kms" : "AES256"}}"
}
