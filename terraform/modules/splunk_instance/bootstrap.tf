data "aws_secretsmanager_secret_version" "splunk_password" {
  secret_id = "/monitoring/splunk/password"

  count = "${var.enabled}"
}

data "aws_secretsmanager_secret_version" "pass4SymmKey" {
  secret_id = "/splunk/pass4SymmKey"
}

data "template_file" "web_conf" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/web_conf.tpl")}"

  vars {
    httpport     = "${var.httpport}"
    mgmtHostPort = "${var.mgmtHostPort}"
  }
}

data "template_file" "user_seed" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/user_seed.tpl")}"

  vars {
    password = "${data.aws_secretsmanager_secret_version.splunk_password.secret_string}"
    splunk_admin_user = "${var.splunk_admin_username}"
  }
}

data "template_file" "deploymentclient_conf" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/deploymentclient_conf.tpl")}"

  vars {
    mgmtHostPort       = "${var.mgmtHostPort}"
    deployment_address = "master.${local.domain}"
  }
}

data "template_file" "serverclass_conf" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/serverclass_conf.tpl")}"

  vars {
    master_address = "master.${local.domain}"
  }
}

data "template_file" "outputs_conf" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/outputs_conf.tpl")}"

  vars {
    master_address = "master.${local.domain}"
    master_port    = "${var.mgmtHostPort}"
    pass4SymmKey   = "${local.pass4SymmKey}"
  }
}

data "template_file" "inputs_conf" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/inputs_conf.tpl")}"

  vars {}
}
#Terraform <0.12 doesnt allow iterations in template files
#so we are using snippets to build up what we need
data "template_file" "master_server_idx_clustering" {
//  count = "${local.enable_idx_clustering}"
  template = "${file("${path.module}/files/snippets/master_server_${var.enable_splunk_indexers==1 ? "" : "no-"}idx_clustering.tpl")}"
  vars {
    pass4SymmKey       = "${local.pass4SymmKey}"
    replication_factor = "${var.replication_factor}"
    search_factor      = "${var.search_factor}"
  }
}

data "template_file" "server_conf" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/server_conf/${var.role}.tpl")}"

  vars {
    additional_config  = "${local.additional_server_conf}"
    master_address     = "master.${local.domain}"
    master_port        = "${var.mgmtHostPort}"
    license_address    = "license.${local.domain}"
    license_port       = "${var.mgmtHostPort}"
    pass4SymmKey       = "${local.pass4SymmKey}"
    replication_port   = "${var.replication_port}"
    replication_factor = "${var.replication_factor}"
    search_factor      = "${var.search_factor}"
    site               = "${ var.availability_zone == "eu-west-2a" ? "site1" : var.availability_zone == "eu-west-2b" ? "site2" : "unknownsite" }"
  }
}

//[deployment-client]
//serverRepositoryLocationPolicy = rejectAlways
//repositoryLocation = \$SPLUNK_HOME/etc/master-apps

#Replace with template_cloudinit_config??
data "template_file" "user_data" {
  count    = "${var.enabled}"
  template = "${file("${path.module}/files/bootstrap/${var.role}.tpl")}"

  vars {
    deploymentclient_conf_content = "${ var.role!= "master" ? data.template_file.deploymentclient_conf.rendered : ""}"
    server_conf_content           = "${data.template_file.server_conf.rendered}"
    serverclass_conf_content      = "${ var.role == "master" ? data.template_file.serverclass_conf.rendered : ""}"
    web_conf_content              = "${data.template_file.web_conf.rendered}"
    inputs_conf_content           = "${data.template_file.inputs_conf.rendered}"
    outputs_conf_content          = "${ var.role!= "master" ? data.template_file.outputs_conf.rendered : ""}"
    user_seed_content             = "${data.template_file.user_seed.rendered}"
    role                          = "${var.role}"
    master_address                = "master.${local.domain}"
    license_address               = "license.${local.domain}"
    private_dns_zone              = "${lookup(local.dns["private-audit"], "zone_id")}"
    public_dns_zone               = "${lookup(local.dns["public-audit"], "zone_id")}"
    s3_resources_bucket           = "${lookup(var.s3["resources"],"name")}"
    s3_pki_bucket                 = "${lookup(var.s3["ma-certs"],"name")}"
    ca_name                       = "${var.cn_name}"
    pass4SymmKey                  = "${local.pass4SymmKey}"
    replication_port              = "${var.replication_port}"
    replication_factor            = "${var.replication_factor}"
    master_port                   = "${var.mgmtHostPort}"
    apps_git_repo                 = "${var.apps_git_repo}"
    splunkcloud_fwd               = "${var.splunkcloud_fwd}"
    splunk_admin_username         = "${var.splunk_admin_username}"

    fqdn                          = "${local.domain}"
    oauth_server                  = "${var.oauth_server}"
    oauth_clientid                = "${var.oauth_clientid}"
    oauth_clientsecret            = "${var.oauth_clientsecret}"
  }
}

data "template_cloudinit_config" "splunk" {
  count = "${var.enabled}"

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"

    content = <<CONTENT
#cloud-config
write_files:
  - content: |
      ${base64encode(data.template_file.user_data.rendered)}
    encoding: b64
    owner: ubuntu:ubuntu
    path: /home/ubuntu/bootstrap.sh
    permissions: '0744'
${var.extra_user_data}
CONTENT
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.user_data.rendered}"
  }
}
