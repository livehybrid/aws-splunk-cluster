environment="example"
account_id="your-aws-account-id"
profile="your-awscli-profile"
state_bucket="your-terraform-state-bucket"

default_vpc_cidr="192.168.84.0/24"
default_subnet_a_cidr="192.168.84.0/26"
default_subnet_b_cidr="192.168.84.64/26"
default_subnet_c_cidr="192.168.84.128/26"

splunk_ami="ami-populate-after-running-packer-build"
slack_alerts_channel="#aws-security"
dns_base_domain="splunk.yourdomain.com"

custom_s3_bucket_access=[
  "arn:aws:s3:::some-extra-bucket/*",
  "arn:aws:s3:::some-extra-bucket",
udability/*"
]
ssl_config={
  ssl_country = "GB",
  ssl_state = "West Yorkshire",
  ssl_city = "Leeds",
  ssl_org = "Your Company",
  ssl_orgunit = "Splunk",
  ssl_email = "splunk@yourcompany.com"
}
pki_cn_name = "splunk.yourcompany.com"
create_dns = true
apps_git_repo = "git.yourcompany.com/splunk-apps.git"
splunkcloud_fwd = "inputs1.yourdestination.com"

trusted_cidrs = [
  "123.123.123.0/24" #YourOfficeIPRange
]

splunk_admin_username = "admin"

oauth_server                  = "git.yourcompany.com"
oauth_clientid                = "your-oauth-client-id"
oauth_clientsecret            = "your-oauth-client-secret"

additional_sts_roles = [
  "arn:aws:iam::*:role/some_audit_role_perhaps"
]
