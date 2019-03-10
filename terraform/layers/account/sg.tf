###########################################################
############ ---- SECURITY GROUPS ONLY ---- ###############
############ ------ NO RULES PLEASE ------ ################
###########################################################

resource "aws_security_group" "management" {
  name        = "management"
  description = "management"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "management"
    source  = "terraform"
    project = "splunk"
  }
}

#THIS IS USED IN THE AUDIT ACCOUNT...
resource "aws_security_group" "splunk" {
  count       = "${var.environment=="audit" ? 1 : 0}"
  name        = "splunk"
  description = "splunk"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_indexer" {
  count       = "${var.enable_splunk_indexer}"
  name        = "splunk-indexer"
  description = "splunk indexer sg"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-indexer"
    source  = "terraform"
    project = "splunk"
  }
}

//resource "aws_security_group" "splunk_common" {
//  name        = "splunk-common"
//  description = "splunk common sg"
//  vpc_id      = "${aws_vpc.default.id}"
//
//  tags {
//    Name    = "splunk-common"
//    source  = "terraform"
//    project = "splunk"
//  }
//}

resource "aws_security_group" "splunk_master" {
  count       = "${var.enable_splunk_master}"
  name        = "splunk-master"
  description = "splunk master sg"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-master"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_license" {
  count       = "${var.enable_splunk_license}"
  name        = "splunk-license"
  description = "splunk license sg"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-license"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_searchhead" {
  count       = "${var.enable_splunk_searchhead}"
  name        = "splunk-searchhead"
  description = "splunk searchhead sg"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-searchhead"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_forwarder" {
  count       = "${var.enable_splunk_forwarder}"
  name        = "splunk-forwarder"
  description = "splunk forwarder sg"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-forwarder"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_searchhead_alb" {
  count       = "${var.enable_splunk_searchhead}"
  name        = "splunk-searchhead-alb"
  description = "splunk searchhead alb sg"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-searchhead-alb"
    source  = "terraform"
    project = "splunk"
  }
}
#TODO: Remove this unused group (Its used in audit account only)
resource "aws_security_group" "splunk_alb" {
  name        = "splunk-alb"
  description = "splunk-alb"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-alb"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_hec_alb" {
  count       = "${var.enable_splunk_forwarder}"
  name        = "splunkhec-alb"
  description = "Splunk HTTP Event Collector ALB"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-hec-alb"
    source  = "terraform"
    project = "splunk"
  }
}

resource "aws_security_group" "splunk_entry_alb" {
  count       = "${var.enable_splunk_searchhead}"
  name        = "splunkentry-alb"
  description = "Splunk Entrypoint ALB"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name    = "splunk-entry-alb"
    source  = "terraform"
    project = "splunk"
  }
}
