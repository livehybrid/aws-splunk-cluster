#aws ec2 describe-volumes --filters Name=tag:Name,Values=splunk-indexer-1-cold --query "Volumes[*].{ID:VolumeId}" | jq -r '.[0]["ID"]'

resource "aws_ebs_volume" "splunkdb_vol_hot" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.hot_disk_size}"
  encrypted         = true

  #Only add this volume for indexers
  count = "${var.role == "indexer" ? var.enabled * var.count : 0}"

  tags {
    Name        = "${var.environment}-${var.role}-${local.az_letter}-${count.index}-hot"
    project     = "splunk-cloud"
    heat        = "hot"
    location    = "${var.availability_zone}"
    indexer_num = "${count.index}"
    environment = "${var.environment}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_ebs_volume" "splunkdb_vol_cold" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.cold_disk_size}"
  encrypted         = true

  #Only add this volume for indexers
  count = "${var.role == "indexer" ? var.enabled * var.count : 0}"

  tags {
    Name        = "${var.environment}-${var.role}-${local.az_letter}-${count.index}-cold"
    project     = "splunk-cloud"
    heat        = "cold"
    location    = "${var.availability_zone}"
    indexer_num = "${count.index}"
    environment = "${var.environment}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_placement_group" "splunk" {
  count = "${var.enabled}"
  name     = "${var.environment}-${var.role}-${local.az_letter}"
  strategy = "cluster"
}

//resource "aws_launch_configuration" "splunk-launchconfig" {
//  name_prefix                 = "${local.name}"
//  image_id                    = "${local.ami_id}"
//  instance_type               = "${var.instance_size}"
//  iam_instance_profile        = "${var.instance_profile_name}"
//  ebs_optimized               = "${var.ebs_optimized}"
//  key_name                    = "${var.keypair_name}"
//  associate_public_ip_address = "${var.associate_public_ip_address}"
//  user_data                   = "${data.template_cloudinit_config.splunk.rendered}"
//
//  //count                       = "${var.count}"
//
//  security_groups = ["${var.security_groups}"]
//  lifecycle {
//    create_before_destroy = true
//  }
//  root_block_device {
//    volume_type           = "gp2"
//    volume_size           = "${var.os_volume_size}"
//    delete_on_termination = true
//  }
//}

resource "aws_launch_template" "splunk" {
  count = "${var.enabled}"

  name = "${local.name}-${local.az_letter}"

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = "${var.os_volume_size}"
    }
  }

  disable_api_termination = false

  ebs_optimized = "${var.ebs_optimized}"

  iam_instance_profile {
    name = "${var.instance_profile_name}"
  }

  image_id = "${var.ami_id}"

  instance_initiated_shutdown_behavior = "terminate"

//  instance_market_options {
//    //market_type = "spot"  //    spot_options {  //      max_price = ""  //    }
//  }

  instance_type = "${var.instance_size}"

  key_name = "${var.keypair_name}"

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = "${var.associate_public_ip_address}"
    //  network_interfaces {
    //    device_index = 1
    subnet_id = "${lookup(local.net["default"], var.availability_zone)}"

    security_groups = ["${var.security_groups}"]
  }

  placement {
    availability_zone = "${var.availability_zone}"
  }

  //security_group_names = ["${var.security_groups}"]


  //  vpc_security_group_ids = [
  //    "${var.security_groups}"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}"
    }
  }
  user_data = "${data.template_cloudinit_config.splunk.rendered}"
}

resource "aws_autoscaling_group" "splunk-asg" {
  name = "${local.name}-${local.az_letter}-${count.index}"

  launch_template {
    id      = "${aws_launch_template.splunk.id}"
    version = "${aws_launch_template.splunk.latest_version}"

    //version = "$$Latest"
  }

  desired_capacity = "${var.asg_desired_size}"
  count            = "${var.enabled * var.count}"

  target_group_arns = [
    "${split(",", var.target_group)}",
  ]

  //placement_group = "${aws_placement_group.splunk.id}"

  min_size = 0
  max_size = "${var.asg_max_size}"
  #target_group_arns = TODO
  vpc_zone_identifier = [
    "${lookup(local.net["default"], var.availability_zone)}",
  ]
  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
  depends_on = ["aws_launch_template.splunk"]
  tags = [
    {
      key                 = "Name"
      value               = "${replace(local.name, "-","_")}_${local.az_letter}_${count.index}"
      propagate_at_launch = true
    },
    {
      key                 = "role"
      value               = "${var.role}"
      propagate_at_launch = true
    },
    {
      key                 = "source"
      value               = "${local.name}"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "splunk-cloud"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
  ]
  lifecycle {
    ignore_changes = [
      "desired_capacity",
      "target_group_arns"
    ]
  }
}
