# All requests with AWS4-HMAC-SHA256 encryption signature will use the S3 default encryption if set
# see https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html and https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTConstructPolicy.html

data "template_file" "policy" {
  template = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    ${join(",",compact(list(
        var.encrypted_bucket ? file("${path.module}/segments/encrypted_bucket.tpl") : "",
        var.prevent_public_access ? file("${path.module}/segments/prevent_public_access.tpl") : "",
        var.required_kms_arn != "" ? file("${path.module}/segments/required_kms_usage.tpl") : "",
        var.ssl_access ? file("${path.module}/segments/ssl_access.tpl") : "")))}
    ]
}
POLICY

  vars {
    bucket_name           = "${var.bucket_name}"
    encryption_type       = "${var.encryption_type}"
    disallowed_encryption = "${local.disallowed_encryption}"
    required_kms_arn      = "${var.required_kms_arn}"
  }
}
