resource "random_string" "ca-password" {
  length = 32
  special = false
}

resource "aws_secretsmanager_secret" "ca-password" {
  name = "/pki/ca-password"
  kms_key_id = "${aws_kms_key.pki.id}"
}

resource "aws_secretsmanager_secret_version" "ca-password" {
  secret_id = "${aws_secretsmanager_secret.ca-password.id}"
  secret_string = "${random_string.ca-password.result}"
}

resource "aws_secretsmanager_secret" "license" {
  name = "/monitoring/splunk/license"
}

resource "aws_secretsmanager_secret_version" "alerts_slack_webhook" {
  secret_id = "${aws_secretsmanager_secret.alerts_slack_webhook.id}"
  secret_string = "UPDATE ME IN AWS CONSOLE"
  lifecycle {
    ignore_changes = ["secret_string"]
  }
}

resource "aws_secretsmanager_secret" "alerts_slack_webhook" {
  name = "/monitoring/alerts/slack_webhook"

}
