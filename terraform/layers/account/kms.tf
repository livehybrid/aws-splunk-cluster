# cloudtrail

resource "aws_kms_key" "cloudtrail" {
  deletion_window_in_days = 7
  description             = "CloudTrail Log Encryption Key"
  enable_key_rotation     = true

  tags {
    Name    = "cloudtrail-key"
    source  = "terraform"
    project = "splunk"
  }

  lifecycle {
    prevent_destroy = true
  }
  //      "Condition": {
  //        "StringLike": {
  //          "kms:EncryptionContext:aws:cloudtrail:arn": [
  //            "arn:aws:cloudtrail:*:${local.account_id}:trail/*"
  //          ]
  //        }
  //      }
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow CloudTrail to encrypt logs",
      "Effect": "Allow",
      "Principal": {
        "Service": ["cloudtrail.amazonaws.com","config.amazonaws.com"]
      },
      "Action": "kms:GenerateDataKey*",
      "Resource": "*"
    },
    {
      "Sid": "Allow CloudWatch Access",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "arn:aws:logs:${var.region}:${local.account_id}:*"
    },
    {
      "Sid": "Allow Describe Key access",
      "Effect": "Allow",
      "Principal": {
        "Service": ["cloudtrail.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Action": "kms:DescribeKey",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail-key"
  target_key_id = "${aws_kms_key.cloudtrail.id}"
}

# sqs-config

resource "aws_kms_key" "sqs-config" {
  deletion_window_in_days = 7
  description             = "Config to SQS Encryption Key"
  enable_key_rotation     = true

  tags {
    Name    = "sqs-config-key"
    source  = "terraform"
    project = "splunk"
  }

  lifecycle {
    prevent_destroy = true
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow SNS Access",
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*",
        "kms:Decrypt*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow SQS Access",
      "Effect": "Allow",
      "Principal": {
        "Service": "sqs.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*",
        "kms:Decrypt*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "sqs-config" {
  name          = "alias/sqs-config-key"
  target_key_id = "${aws_kms_key.sqs-config.id}"
}

# kinesis

resource "aws_kms_key" "kinesis" {
  deletion_window_in_days = 7
  description             = "Kinesis Log Encryption Key"
  enable_key_rotation     = true

  tags {
    Name    = "kinesis-key"
    source  = "terraform"
    project = "splunk"
  }

  lifecycle {
    prevent_destroy = true
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow Kinesis to encrypt logs",
      "Effect": "Allow",
      "Principal": {
        "Service": "kinesis.amazonaws.com"
      },
      "Action": "kms:GenerateDataKey*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "kinesis" {
  name          = "alias/kinesis-key"
  target_key_id = "${aws_kms_key.kinesis.id}"
}



resource "aws_kms_key" "pki" {
  deletion_window_in_days = 7
  description             = "PKI Encryption Key"
  enable_key_rotation     = true

  tags {
    Name    = "pki-key"
    source  = "terraform"
    project = "splunk"
  }

  lifecycle {
    prevent_destroy = true
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${local.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow Lambda to Access",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "pki" {
  name          = "alias/pki-key"
  target_key_id = "${aws_kms_key.pki.id}"
}


