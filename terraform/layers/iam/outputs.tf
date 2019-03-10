locals {
  roles = {
    ops = {
      name                  = "${aws_iam_role.ops.name}"
      instance_profile_name = "${aws_iam_instance_profile.ops.name}"
      instance_profile_arn  = "${aws_iam_instance_profile.ops.arn}"
      role_id               = "${aws_iam_instance_profile.ops.id}"
    }

    splunk = {
      name                  = "${var.environment=="audit" ? element(concat(aws_iam_role.splunk.*.name,list("")),0) : ""}"
      instance_profile_name = "${var.environment=="audit" ? element(concat(aws_iam_role.splunk.*.name,list("")),0) : ""}"
      instance_profile_arn  = "${var.environment=="audit" ? element(concat(aws_iam_role.splunk.*.arn,list("")),0) : ""}"
      role_id               = "${var.environment=="audit" ? element(concat(aws_iam_role.splunk.*.id,list("")),0) : ""}"
    }

//    splunk-generic = {
//      name                  = "${aws_iam_role.splunk_generic.name}"
//      instance_profile_name = "${aws_iam_instance_profile.splunk_generic.name}"
//      instance_profile_arn  = "${aws_iam_instance_profile.splunk_generic.arn}"
//      role_id               = "${aws_iam_instance_profile.splunk_generic.id}"
//    }

    splunk-sh = {
      name                  = "${aws_iam_role.splunk_sh.name}"
      instance_profile_name = "${aws_iam_instance_profile.splunk_sh.name}"
      instance_profile_arn  = "${aws_iam_instance_profile.splunk_sh.arn}"
      role_id               = "${aws_iam_instance_profile.splunk_sh.id}"
    }

    splunk-master = {
      name                  = "${aws_iam_role.splunk_master.name}"
      instance_profile_name = "${aws_iam_instance_profile.splunk_master.name}"
      instance_profile_arn  = "${aws_iam_instance_profile.splunk_master.arn}"
      role_id               = "${aws_iam_instance_profile.splunk_master.id}"
    }

    splunk-license = {
      name                  = "${aws_iam_role.splunk_license.name}"
      instance_profile_name = "${aws_iam_instance_profile.splunk_license.name}"
      instance_profile_arn  = "${aws_iam_instance_profile.splunk_license.arn}"
      role_id               = "${aws_iam_instance_profile.splunk_license.id}"
    }

    splunk-forwarder = {
      name                  = "${aws_iam_role.splunk_forwarder.name}"
      instance_profile_name = "${aws_iam_instance_profile.splunk_forwarder.name}"
      instance_profile_arn  = "${aws_iam_instance_profile.splunk_forwarder.arn}"
      role_id               = "${aws_iam_instance_profile.splunk_forwarder.id}"
    }

    splunk-indexer = {
      name                  = "${aws_iam_role.splunk_idx.name}"
      instance_profile_name = "${aws_iam_instance_profile.splunk_idx.name}"
      instance_profile_arn  = "${aws_iam_instance_profile.splunk_idx.arn}"
      role_id               = "${aws_iam_instance_profile.splunk_idx.id}"
    }

  }
}

output "roles" {
  value = "${local.roles}"
}

