Creating a new environment:

Install awscli, packer, terraform

0) Setup your ~/.aws/credentials file with a profile for the account you wish to use.
1)Navigate to terraform/layers/_shared/vars

2)Clone an existing vars file (e.g. audit) and rename to your new env name (e.g. audit-ptl)
3)Update the variables in your new file

#This is different to the above - used for backend
4)Navigate to terraform/layers/_shared/conf
5)Clone an existing vars file (e.g. audit) and rename to your new env name (e.g. audit-ptl)
6)Update the variables in your new file


10) Create an S3 bucket in the target account matching the name in the above vars files

13) Navigate to terraform/layers/account

14) Run make terraform-clean
15) Run `make terraform env=audit-ptl`

16) Navigate to terraform/layers/iam
17) Run `make terraform env=audit-ptl




18) Insert slack hook at /monitoring/alerts/slack_webhook
`
Go to https://eu-west-2.console.aws.amazon.com/vpc/home?region=eu-west-2#subnets:sort=SubnetId
Make a note of the subnet ID for "default-a"

#This is different to the above - used for packer
7)Navigate to packer/_shared/vars/
8)Clone an existing vars file (e.g. audit) and rename to your new env name (e.g. audit-ptl)
9)Update the variables in your new file

Visit https://aws.amazon.com/marketplace/pp/B07CQ33QKV/ in your new AWS account to accept the Terms for the Ubuntu image.


21) #export AWS_PROFILE=your-rofile
21) Run cd packer/splunk && make packer-build env=audit-ptl`
Copy the ami-xxxxxxxxx output into the variable file in /terraform/layers/_shared/vars/

Configure license in Secrets Manager /monitoring/splunk/license
Configure a valid git login in secrets manager under /git/login

22) Navigate to /terraform/layers/cluster
23) Run `make terraform env=audit-ptl`

SSH to your environment from a trusted IP with:
Ssh ubuntu@bastion.your-fqdn.

