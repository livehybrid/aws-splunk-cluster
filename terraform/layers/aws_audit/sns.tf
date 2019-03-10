resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts-topic"
  display_name = "Security Alerts"
}

resource "aws_sns_topic_subscription" "lambda_alert" {
  topic_arn = "${aws_sns_topic.security_alerts.arn}"
  protocol = "lambda"
  endpoint = "${aws_lambda_function.slack_notify.arn}"
}

resource "aws_sns_topic" "config_change" {
  name = "config_change"
  display_name = "AWS Confsig change detection"
  kms_master_key_id = "${lookup(local.kms["sqs-config"],"arn")}"
}

resource "aws_sns_topic_subscription" "config_change_to_sqs" {
  topic_arn = "${aws_sns_topic.config_change.arn}"
  protocol = "sqs"
  endpoint = "${aws_sqs_queue.config_change.arn}"
}

resource "aws_sqs_queue" "config_change" {
  name = "config-changes"

  tags {
    Name = "AWS Config Change detection"
    source = "terraform"
    project = "core"
  }
  #https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-server-side-encryption.html
  kms_master_key_id = "${lookup(local.kms["sqs-config"],"arn")}"
  #kms_data_key_reuse_period_seconds = 300
  delay_seconds = 90
  visibility_timeout_seconds = 300
  max_message_size = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.config_change_deadletter.arn}\",\"maxReceiveCount\":10}"
}

resource "aws_sqs_queue" "config_change_deadletter" {
  name = "config-changes-deadletter"
  kms_master_key_id = "${lookup(local.kms["sqs-config"],"arn")}"
  #kms_data_key_reuse_period_seconds = 300

  tags {
    Name = "AWS Config Change detection - Deadletter"
    source = "terraform"
    project = "core"
  }
}


data "external" "org_accounts" {
  program = [
    "python",
    "${path.module}/get_org_accounts.py"]
}
resource "aws_sqs_queue_policy" "sns_to_sqs" {
  queue_url = "${aws_sqs_queue.config_change.id}"

  policy = <<EOF
{
"Version":"2012-10-17",
"Statement":[
  {
    "Effect":"Allow",
    "Principal":"*",
    "Action":"sqs:SendMessage",
    "Resource":"${aws_sqs_queue.config_change.arn}",
    "Condition":{
     "ArnEquals":{
        "aws:SourceArn":"${aws_sns_topic.config_change.arn}"
      }
    }
  }
]
}
EOF
}

data "aws_iam_policy_document" "sns_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "s3.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      "${aws_sns_topic.config_change.arn}"
    ]
    condition {
      test = "ArnLike"
      values = ["${lookup(local.s3["cloudtrail"], "arn")}"]
      variable = "aws:SourceArn"
    }
    sid = "AllowS3ToSend"
  }


  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "${local.all_account_ids}"
      ]
      type = "AWS"
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      "${aws_sns_topic.config_change.arn}"
    ]
//    condition {
//      test = "ArnLike"
//      values = ["${aws_sns_topic.config_change.arn}"]
//      variable = "aws:SourceArn"
//    }
    sid = "AllowOurAccountsToSendConfig"
  }
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn = "${aws_sns_topic.config_change.arn}"
  policy = "${data.aws_iam_policy_document.sns_policy.json}"
}

resource "aws_s3_bucket_notification" "config_s3_notification" {
  bucket = "${lookup(local.s3["cloudtrail"],"name")}"

  topic {
    topic_arn = "${aws_sns_topic.config_change.arn}"
    events = [
      "s3:ObjectCreated:*"]
    filter_prefix = "config"
  }
}

data "aws_iam_policy_document" "splunk_sns_policy" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [
      "${aws_sqs_queue.config_change.arn}"
    ]
  }

  statement {
    actions = [
      "sqs:ListQueues"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    resources = [
      "${aws_sns_topic.config_change.arn}"
    ]
  }
}

resource "aws_iam_role_policy" "splunk" {
  count = "${var.environment == "audit" ? 1 : 0}"
  name = "snsaccess"
  role = "${lookup(local.roles["splunk"], "role_id")}"
  policy = "${data.aws_iam_policy_document.splunk_sns_policy.json}"
}