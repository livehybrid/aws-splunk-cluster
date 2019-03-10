resource "aws_secretsmanager_secret" "kinesis-hec" {
name = "/splunk/hec/kinesis"
}


resource "aws_secretsmanager_secret_version" "kinesis-hec" {
  secret_id = "${aws_secretsmanager_secret.kinesis-hec.id}"
  secret_string = "${uuid()}"
  lifecycle {
    #uuid makes a new uuid each time..
    ignore_changes = ["secret_string"]
  }
}


resource "aws_kinesis_firehose_delivery_stream" "splunk_stream" {
  name        = "hec-splunk-stream"
  destination = "splunk"

  s3_configuration {
    role_arn           = "${aws_iam_role.firehose.arn}"
    bucket_arn         = "${aws_s3_bucket.cloudtrail.arn}"
    prefix             = "kinesis"
    buffer_size        = 10
    buffer_interval    = 60
    compression_format = "GZIP"
    kms_key_arn = "${aws_kms_key.kinesis.arn}"
  }

  splunk_configuration {
    hec_endpoint               = "https://collector.${var.dns_base_domain}"
    hec_token                  = "${aws_secretsmanager_secret_version.kinesis-hec.secret_string}"
    hec_acknowledgment_timeout = 300
    hec_endpoint_type          = "Raw"
    s3_backup_mode             = "FailedEventsOnly"
    processing_configuration {
      enabled = false
    }
  }


}

resource "aws_iam_role" "firehose" {
  name = "audit-hec-splunk-stream-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
