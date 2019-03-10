# -----------------------------------------------------------
# aws config
# -----------------------------------------------------------
resource "aws_iam_role" "config" {
  name = "InternalAWSConfig"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}
data "aws_iam_policy_document" "read_write_access_to_cloudtrail_bucket" {

  statement {
    actions = ["s3:HeadBucket"]
    resources = ["*"]
  }

  statement {
    actions = [
      "${local.iam_s3_read_write_actions}",
      "${local.iam_s3_list_bucket_actions}"
    ]
    resources = [
      "arn:aws:s3:::${local.cloudtrail_bucket}",
      "arn:aws:s3:::${local.cloudtrail_bucket}/*"
    ]
  }

  statement {
    actions = [
      "${local.iam_kms_encrypt_actions}"
    ]
    resources = ["${lookup(local.kms["cloudtrail"], "arn")}"]
  }

}

resource "aws_iam_policy" "read_write_access_to_cloudtrail_bucket" {
  name = "AWSConfigToCloudtrailBucketReadWriteAccess"
  path = "/"
  description = "Read write access to S3 bucket cloudtrail for AWS Config"

  policy = "${data.aws_iam_policy_document.read_write_access_to_cloudtrail_bucket.json}"
}

resource "aws_iam_role_policy_attachment" "cloudtrail_bucket_policy" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "${aws_iam_policy.read_write_access_to_cloudtrail_bucket.arn}"
}

# -----------------------------------------------------------
# setup permissions to allow cloudtrail to write to cloudwatch
# -----------------------------------------------------------
resource "aws_iam_role" "cloudtrail" {
  name = "cloudtrail-to-cloudwatch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail" {
  name = "cloudtrail"
  role = "${aws_iam_role.cloudtrail.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream"],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents",
      "Effect": "Allow",
      "Action": ["logs:PutLogEvents"],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:*"
      ]
    }
  ]
}
EOF
}

# -----------------------------------------------------------
# setup permissions lamba to monitor sns and post to slack
# -----------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name = "sns-lambda"

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


resource "aws_iam_role_policy" "lambda-slack-policy" {
  name = "lambda-cloudwatch-policy"
  role = "${aws_iam_role.lambda.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        },
        {
            "Sid": "AllowAccessToWebHookSecretsManager",
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameter"
            ],
            "Resource": [
              "${lookup(local.secrets["slack-webook"], "arn")}"
            ]
        }
    ]
}
EOF
}
