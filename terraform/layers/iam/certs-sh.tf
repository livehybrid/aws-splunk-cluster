//data "local_file" "sh_crt" {
//  filename = "certs/sh.crt"
//}
//resource "aws_secretsmanager_secret" "sh_crt" {
//  name = "/splunk/sh/int/crt"
//}
//resource "aws_secretsmanager_secret_version" "sh_crt" {
//  secret_id = "${aws_secretsmanager_secret.sh_crt.id}"
//  secret_string = "${data.local_file.sh_crt.content}"
//}
//
//data "local_file" "sh_key" {
//  filename = "certs/sh.key"
//}
//resource "aws_secretsmanager_secret" "sh_key" {
//  name = "/splunk/sh/int/key"
//}
//resource "aws_secretsmanager_secret_version" "sh_key" {
//  secret_id = "${aws_secretsmanager_secret.sh_key.id}"
//  secret_string = "${data.local_file.sh_key.content}"
//}