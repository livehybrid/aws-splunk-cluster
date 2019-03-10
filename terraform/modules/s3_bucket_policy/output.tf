output "json" {
  value = "${data.template_file.policy.rendered}"
}
