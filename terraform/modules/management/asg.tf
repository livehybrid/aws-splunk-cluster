data "template_file" "bootstrap" {
  template = "${file("${path.module}/files/bootstrap.sh")}"

  vars {
    env = "${var.environment}"
    public_dns_zone = "${lookup(var.dns["public-audit"], "zone_id")}"
    fqdn  = "${local.fqdn}"
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/files/install_ssh_key.sh")}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bootstrap.rendered}"
  }
}

resource "aws_launch_configuration" "management" {
  name_prefix                 = "${var.name}"
  image_id                    = "${local.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.instance_profile_arn}"
  ebs_optimized               = false
  key_name                    = "${var.keypair_name}"
  associate_public_ip_address = false

  security_groups = ["${var.sg_id}"]

  user_data = "${data.template_cloudinit_config.config.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 40
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "management" {
  name                 = "${var.name}-asg"
  launch_configuration = "${aws_launch_configuration.management.name}"
  desired_capacity     = "${var.min_size}"

  min_size = "${var.min_size}"
  max_size = 2

  vpc_zone_identifier = [
    "${var.subnet_ids}",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "${var.name}"
      propagate_at_launch = true
    },
    {
      key                 = "source"
      value               = "${var.name}-asg"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "splunk"
      propagate_at_launch = true
    },
  ]

  lifecycle {
    ignore_changes = [
      "desired_capacity",
      "min_size",
    ]
  }
}

resource "aws_security_group_rule" "management_from_self" {
  description       = "from self"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${var.sg_id}"
  to_port           = 22
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "management_to_self" {
  description       = "to self"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${var.sg_id}"
  to_port           = 22
  type              = "egress"
  self              = true
}
