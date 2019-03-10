#!/usr/bin/env bash

set -e

sudo echo "Host *" > /home/ubuntu/.ssh/config
sudo echo "    StrictHostKeyChecking no" >> /home/ubuntu/.ssh/config
sudo echo "" >> /home/ubuntu/.ssh/config

sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/config
sudo chmod 600 /home/ubuntu/.ssh/config


# Wait for an EIP to be allocated and associated by the Controller
ipv4=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
while [[ ! $ipv4 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];do
sleep 2
ipv4=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
done
echo $ipv4 is the public-ipv4


cat <<EOF | sudo tee /tmp/dns.json
{
"Comment": "Register bastion with DNS",
"Changes": [{
"Action": "UPSERT",
"ResourceRecordSet": {
"Name": "bastion.${fqdn}",
"Type": "A",

"TTL": 90,
"ResourceRecords": [{ "Value": "$ipv4"}]
}}]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id ${public_dns_zone} --change-batch file:///tmp/dns.json
