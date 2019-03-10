#!/bin/bash
set -x
exec 1> /var/tmp/startup.log 2>&1

#Fix NTP
cat <<EOF | sudo tee /etc/systemd/timesyncd.conf
[Time]
NTP=169.254.169.123
EOF
sudo systemctl restart systemd-timesyncd.service
sleep 10


# Create local config files
sudo -u splunk mkdir -p /opt/splunk/etc/system/local
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/deploymentclient.conf
${deploymentclient_conf_content}
EOF
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/web.conf
${web_conf_content}
EOF
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/inputs.conf
${inputs_conf_content}
EOF
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/server.conf
${server_conf_content}
EOF
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/outputs.conf
${outputs_conf_content}
EOF
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/serverclass.conf
${serverclass_conf_content}
EOF
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/user-seed.conf
${user_seed_content}
EOF
chown -R splunk: /opt/splunk


# Update hostname
INSTANCE_ID=$(ec2metadata --instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region=$REGION --output=text | cut -f5)

hostname $${INSTANCE_NAME//_/-}
echo `hostname` > /etc/hostname
sed -i 's/localhost$/localhost '`hostname`'/' /etc/hosts

mkdir -p /opt/splunk/etc/auth/customcerts/
echo "Generating SSL Key/Cert"
aws lambda invoke --function-name get_sslcert --payload "{\"domain\":\"$(hostname).${fqdn}\"}" /tmp/certs.json
cat  /tmp/certs.json | jq -r '.' | jq -r '.crt' > /opt/splunk/etc/auth/customcerts/server.crt
cat  /tmp/certs.json | jq -r '.' | jq -r '.key' > /opt/splunk/etc/auth/customcerts/server.key

#Get CA crt
aws s3 cp s3://${s3_pki_bucket}/ca/${ca_name}.crt /opt/splunk/etc/auth/customcerts/ca.crt
cat /opt/splunk/etc/auth/customcerts/server.crt /opt/splunk/etc/auth/customcerts/server.key /opt/splunk/etc/auth/customcerts/ca.crt > /opt/splunk/etc/auth/customcerts/server_combined.pem
chown -R splunk:splunk /opt/splunk/etc/auth/customcerts/


localIP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
cat <<EOF | sudo -u splunk tee /tmp/dns.json
{
"Comment": "Register master with DNS",
"Changes": [{
"Action": "UPSERT",
"ResourceRecordSet": {
"Name": "${master_address}",
"Type": "A",

"TTL": 90,
"ResourceRecords": [{ "Value": "$localIP"}]
}}]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id ${private_dns_zone} --change-batch file:///tmp/dns.json

# Wait for an external IP to be allocated and associated by the Controller
ipv4=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
while [[ ! $ipv4 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];do
sleep 20
done
external_ip=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
echo $external_ip is the public-ipv4
cat <<EOF | sudo -u splunk tee /tmp/dns.json
{
"Comment": "Register master with DNS",
"Changes": [{
"Action": "UPSERT",
"ResourceRecordSet": {
"Name": "${master_address}",
"Type": "A",

"TTL": 90,
"ResourceRecords": [{ "Value": "$external_ip"}]
}}]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id ${public_dns_zone} --change-batch file:///tmp/dns.json


# Start service and Enable autostart
sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license

#Pull in deployment apps from git
echo "Checking out apps repo"
cd /opt/splunk/etc/
git init
git config user.email "splunk-master@local"
git config user.name "splunk-master"
git remote add origin https://$(aws secretsmanager get-secret-value --secret-id /git/login | jq -r '.SecretString')@${apps_git_repo}
git fetch --all
git reset --hard origin/master
echo "Replacing Secret placeholders with actual secrets"
grep -Rl splunksecret /opt/splunk/etc/ | xargs sed  -i -E 's/(.*)#splunksecret\:([^#]+)#(.*)/echo "\1$(aws secretsmanager get-secret-value --secret-id \2 | jq -r '.SecretString')\3"/eg'


openssl s_client -showcerts -verify 5 -connect ${splunkcloud_fwd}:9997 < /dev/null 2> /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print >>"/opt/splunk/etc/auth/customcerts/ca.crt"}'

sudo systemctl restart Splunkd


