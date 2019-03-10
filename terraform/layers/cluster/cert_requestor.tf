data "template_file" "get_sslcert_python" {
  template = "${file("${path.module}/files/get_sslcert/get_sslcert.py")}"
  vars = "${var.ssl_config}"
}

//output "test" {
//  value = "${data.template_file.get_sslcert_python.rendered}"
//}

data "archive_file" "get_sslcert_zip" {
  type        = "zip"
//  source_dir = "${path.module}/files/get_sslcert"
  source {
    content  = "${data.template_file.get_sslcert_python.rendered}"
    filename = "get_sslcert.py"
  }
  output_path = "${path.module}/files/get_sslcert.zip"
  depends_on = ["data.template_file.get_sslcert_python"]
}

resource "aws_lambda_function" "get_sslcert" {
  filename         = "${path.module}/files/get_sslcert.zip"
  function_name    = "get_sslcert"
  role             = "${aws_iam_role.lambda-getcerts.arn}"
  handler          = "get_sslcert.handler"
  runtime          = "python3.6"
  source_code_hash = "${base64sha256(file("${path.module}/files/get_sslcert.zip"))}"

  depends_on = [
    "data.archive_file.get_sslcert_zip",
  ]

  environment {
    variables = {
      bucket  = "${lookup(local.s3["ma-certs"],"name")}"
      kms     = "${lookup(local.kms["pki"],"arn")}"
      ca_name = "${var.pki_cn_name}"
    }
  }
}


# -----------------------------------------------------------
# setup permissions lamba to monitor sns and post to slack
# -----------------------------------------------------------
resource "aws_iam_role" "lambda-getcerts" {
  name = "lambda-getcerts"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda-getcerts" {

  "statement" {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["arn:aws:logs:eu-west-2:*:log-group:/aws/lambda/${aws_lambda_function.get_sslcert.function_name}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "${lookup(local.secrets["ca-password"],"arn")}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "${local.iam_s3_read_write_actions}"
    ]
    resources = [
      "${lookup(local.s3["ma-certs"],"arn")}",
      "${lookup(local.s3["ma-certs"],"arn")}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "${local.iam_kms_encrypt_decrypt_actions}"
    ]
    resources = [
      "${lookup(local.kms["pki"],"arn")}"
    ]

  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [
      "${aws_dynamodb_table.certificates.arn}"
    ]

  }

}
resource "aws_iam_role_policy" "lambda-getcerts" {
  name = "lambda-getcerts"
  role = "${aws_iam_role.lambda-getcerts.id}"

  policy = "${data.aws_iam_policy_document.lambda-getcerts.json}"

}

data "aws_iam_policy_document" "ec2_getssl" {
  statement {
    actions = ["lambda:InvokeFunction"]
    resources = ["${aws_lambda_function.get_sslcert.arn}"]
  }
}

#Allow SH to getcert
resource "aws_iam_role_policy" "splunk_sh_secrets" {
  count = "${var.enable_splunk_searchhead}"

  name   = "get_ssl_certs"
  role   = "${lookup(local.roles["splunk-sh"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
}

#Allow Generic to getcert
//resource "aws_iam_role_policy" "splunk_generic_secrets" {
//  name   = "get_ssl_certs"
//  role   = "${lookup(local.roles["splunk-generic"],"role_id")}"
//  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
//}

#Allow Default Splunk role to getcert
resource "aws_iam_role_policy" "splunk_secrets" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name   = "get_ssl_certs"
  role   = "${lookup(local.roles["splunk"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
}

#Allow Master Splunk role to getcert
resource "aws_iam_role_policy" "splunk_master_secrets" {
  count = "${var.enable_splunk_master}"

  name   = "get_ssl_certs"
  role   = "${lookup(local.roles["splunk-master"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
}

#Allow license Splunk role to getcert
resource "aws_iam_role_policy" "splunk_license_secrets" {
  count = "${var.enable_splunk_license}"

  name   = "get_ssl_certs"
  role   = "${lookup(local.roles["splunk-license"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
}

#Allow indexer Splunk role to getcert
resource "aws_iam_role_policy" "splunk_idx_secrets" {
  count = "${var.enable_splunk_indexer}"

  name   = "get_ssl_certs"
  role   = "${lookup(local.roles["splunk-indexer"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
}

#Allow forwarder Splunk role to getcert
resource "aws_iam_role_policy" "splunk_forwarder_secrets" {
  count = "${var.enable_splunk_forwarder}"

  name   = "get_ssl_certs"
  role   = "${lookup(local.roles["splunk-forwarder"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_getssl.json}"
}
