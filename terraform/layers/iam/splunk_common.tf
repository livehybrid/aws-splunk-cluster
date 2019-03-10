#SPLUNK sym password
resource "random_string" "splunk_pass4SymmKey" {
length = 9
special = false
}

resource "aws_secretsmanager_secret" "splunk_pass4SymmKey" {
name = "/splunk/pass4SymmKey"
}

resource "aws_secretsmanager_secret_version" "splunk_pass4SymmKey" {
secret_id = "${aws_secretsmanager_secret.splunk_pass4SymmKey.id}"
secret_string = "${random_string.splunk_pass4SymmKey.result}"

}

#SPLUNK Admin password
resource "random_string" "splunk_admin_password" {
length = 12
special = false
}

resource "aws_secretsmanager_secret" "splunk_admin_password" {
name = "/monitoring/splunk/password"
}

resource "aws_secretsmanager_secret_version" "splunk_password" {
secret_id = "${aws_secretsmanager_secret.splunk_admin_password.id}"
secret_string = "${random_string.splunk_admin_password.result}"
}

#SPLUNK Encryption key
resource "random_string" "splunk_secret_key" {
  length = 254
  special = false
}

resource "aws_secretsmanager_secret" "splunk_secret_key" {
  name = "/monitoring/splunk/secret_key"
}

resource "aws_secretsmanager_secret_version" "splunk_secret_key" {
  secret_id     = "${aws_secretsmanager_secret.splunk_secret_key.id}"
  secret_string = "${random_string.splunk_secret_key.result}"
}


data "aws_iam_policy_document" "sns-security-alert" {

  statement {
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:eu-west-2:${local.account_id}:security-alerts-topic"]
  }

  statement {
    actions = [
      "sns:ListTopics",
    ]

    resources = ["*"]
  }

}
data "aws_iam_policy_document" "sqs-config-changes" {

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = ["arn:aws:sqs:eu-west-2:${local.account_id}:config-changes"]
  }

  statement {
    actions = [
      "sqs:ListQueues",
    ]

    resources = ["*"]
  }

}
data "aws_iam_policy_document" "splunk" {

  statement {
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "${local.iam_s3_list_bucket_actions}",
    ]

    resources = [
      "${lookup(local.s3["cloudtrail"], "arn")}",
      "${lookup(local.s3["resources"], "arn")}",
      "${lookup(local.s3["ma-certs"], "arn")}",
      "${lookup(local.s3["cwlogs"], "arn")}"
    ]
  }

  statement {
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "${local.iam_s3_list_bucket_actions}",
    ]

    resources = [
      "${lookup(local.s3["cloudtrail"], "arn")}/*",
      "${lookup(local.s3["resources"], "arn")}/*",
      "${lookup(local.s3["ma-certs"], "arn")}/*",
      "${lookup(local.s3["cwlogs"], "arn")}/*"
    ]
  }

  statement {
    actions = [
      "${local.iam_s3_read_only_actions}",
    ]

    resources = [
      "${lookup(local.s3["cloudtrail"], "arn")}/*",
      "${lookup(local.s3["resources"], "arn")}/*",
      "${lookup(local.s3["ma-certs"], "arn")}/*",
      "${lookup(local.s3["cwlogs"], "arn")}/*"
    ]
  }
  statement {
    actions = [
      "${local.iam_kms_decrypt_actions}"
    ]

    resources = [
      "${lookup(local.kms["cloudtrail"],"arn")}",
      "${lookup(local.kms["sqs-config"],"arn")}"
    ]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "ssm:GetParameters"
    ]

    resources = [
      "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:/monitoring/splunk/*",
      "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:/splunk/*",
      "arn:aws:secretsmanager:eu-west-2:${local.account_id}:secret:/monitoring/alerts/slack_webhook",
      "arn:aws:ssm:eu-west-2:${local.account_id}:parameter/aws/reference/secretsmanager//splunk/*"
    ]
  }

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${var.additional_sts_roles}"
    ]
  }

  statement {
    actions = [
      "support:DescribeTrustedAdvisorCheckResult",
      "support:DescribeTrustedAdvisorCheckSummaries",
      "support:DescribeServices",
      "support:DescribeTrustedAdvisorCheckRefreshStatuses",
      "support:DescribeTrustedAdvisorChecks",
      "support:DescribeSeverityLevels",
      "support:RefreshTrustedAdvisorCheck"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${lookup(local.dns["private-audit"], "zone_id")}"
    ]
  }

}
data "aws_iam_policy_document" "s3_ca_crt_access" {
  "statement" {
    actions = [
      "${local.iam_s3_read_only_actions}"
    ]
    resources = [
      "${lookup(local.s3["ma-certs"],"arn")}/ca/*.crt"
    ]
  }

  "statement" {
    actions = [
      "${local.iam_kms_decrypt_actions}"
    ]
    resources = [
      "${lookup(local.kms["pki"], "arn")}"
    ]
  }
}

data "aws_iam_policy_document" "lambda_get_lic_auth_certs" {
  "statement" {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:eu-west-2:*:function:get_authorisedcerts"
    ]
  }

}