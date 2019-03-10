resource "aws_s3_bucket_object" "haproxy_config" {
  bucket = "${var.bucket}"
  key = "${var.path}/ma-proxy/haproxy.cfg"
  source = "${path.module}/files/haproxy.cfg"
  etag   = "${md5(file("${path.module}/files/haproxy.cfg"))}"
}

variable "bucket" {}
variable "path" {
  default = ""
}