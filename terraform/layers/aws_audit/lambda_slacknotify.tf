data "archive_file" "slack_notify_zip" {
  type        = "zip"
  source_file = "${path.module}/files/slack_notify.py"
  output_path = "${path.module}/files/slack_notify.zip"
}

resource "aws_lambda_function" "slack_notify" {
  filename         = "${path.module}/files/slack_notify.zip"
  function_name    = "slack_notify"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "slack_notify.handler"
  runtime          = "python3.6"
  source_code_hash = "${data.archive_file.slack_notify_zip.output_base64sha256}"

  depends_on = [
    "data.archive_file.slack_notify_zip",
  ]

  environment {
    variables = {
      slack_channel = "${var.slack_alerts_channel}"
      account_name  = "${local.account_name}"
    }
  }
}

resource "aws_lambda_permission" "from_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.slack_notify.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.security_alerts.arn}"
}