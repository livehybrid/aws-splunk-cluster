data "archive_file" "get_authorisedcerts_zip" {
  type        = "zip"
  source_dir = "${path.module}/files/get_authorisedcerts"
  output_path = "${path.module}/files/get_authorisedcerts.zip"
}

resource "aws_lambda_function" "get_authorisedcerts" {
  filename         = "${path.module}/files/get_authorisedcerts.zip"
  function_name    = "get_authorisedcerts"
  role             = "${aws_iam_role.lambda-getauthorisedcerts.arn}"
  handler          = "get_authorisedcerts.handler"
  runtime          = "python3.6"
  source_code_hash = "${data.archive_file.get_authorisedcerts_zip.output_base64sha256}"

  depends_on = [
    "data.archive_file.get_authorisedcerts_zip",
  ]

//  environment {
//    variables = {
//      bucket  = "${lookup(local.s3["ma-certs"],"name")}"
//      kms     = "${lookup(local.kms["pki"],"arn")}"
//    }
//  }
}


# -----------------------------------------------------------
# setup permissions lamba to monitor sns and post to slack
# -----------------------------------------------------------
resource "aws_iam_role" "lambda-getauthorisedcerts" {
  name = "lambda-getauthorisedcerts"

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

data "aws_iam_policy_document" "lambda-getauthorisedcerts" {

  "statement" {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["arn:aws:logs:eu-west-2:*:log-group:/aws/lambda/${aws_lambda_function.get_authorisedcerts.function_name}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query"
    ]
    resources = [
      "${aws_dynamodb_table.certificates.arn}",
      "${aws_dynamodb_table.certificates.arn}/*"
    ]

  }

}
resource "aws_iam_role_policy" "lambda-getauthorisedcerts" {
  name = "lambda-getcerts"
  role = "${aws_iam_role.lambda-getauthorisedcerts.id}"

  policy = "${data.aws_iam_policy_document.lambda-getauthorisedcerts.json}"

}

data "aws_iam_policy_document" "ec2_lambda_getauthorisedcerts" {
  statement {
    actions = ["lambda:InvokeFunction"]
    resources = ["${aws_lambda_function.get_authorisedcerts.arn}"]
  }
}

#Allow SH to getauthorisedcerts
resource "aws_iam_role_policy" "splunk_sh_lambda_getauthorisedcerts" {
  count = "${var.enable_splunk_searchhead}"

  name   = "get_authorisedcerts"
  role   = "${lookup(local.roles["splunk-sh"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_lambda_getauthorisedcerts.json}"
}

#Allow Generic to getauthorisedcerts
//resource "aws_iam_role_policy" "splunk_generic_lambda_getauthorisedcerts" {
//  name   = "get_authorisedcerts"
//  role   = "${lookup(local.roles["splunk-generic"],"role_id")}"
//  policy = "${data.aws_iam_policy_document.ec2_lambda_getauthorisedcerts.json}"
//}

#Allow Default Splunk role to getauthorisedcerts
resource "aws_iam_role_policy" "splunk_lambda_getauthorisedcerts" {
  count  = "${var.environment=="audit" ? 1 : 0}"
  name   = "get_authorisedcerts"
  role   = "${lookup(local.roles["splunk"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_lambda_getauthorisedcerts.json}"
}

#Allow Default Splunk master to getauthorisedcerts
resource "aws_iam_role_policy" "splunk_master_lambda_getauthorisedcerts" {
  count = "${var.enable_splunk_master}"

  name   = "get_authorisedcerts"
  role   = "${lookup(local.roles["splunk-master"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_lambda_getauthorisedcerts.json}"
}

#Allow Default Splunk license to getauthorisedcerts
resource "aws_iam_role_policy" "splunk_license_lambda_getauthorisedcerts" {
  count = "${var.enable_splunk_license}"

  name   = "get_authorisedcerts"
  role   = "${lookup(local.roles["splunk-license"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_lambda_getauthorisedcerts.json}"
}

#Allow Default Splunk forwarder to getauthorisedcerts
resource "aws_iam_role_policy" "splunk_forwarder_lambda_getauthorisedcerts" {
  count = "${var.enable_splunk_forwarder}"

  name   = "get_authorisedcerts"
  role   = "${lookup(local.roles["splunk-forwarder"],"role_id")}"
  policy = "${data.aws_iam_policy_document.ec2_lambda_getauthorisedcerts.json}"
}

