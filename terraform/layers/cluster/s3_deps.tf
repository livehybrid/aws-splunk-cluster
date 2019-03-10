module "haproxy_deps" {
  source = "../../modules/ma-proxy"
  bucket = "${lookup(local.s3["resources"],"name")}"
}