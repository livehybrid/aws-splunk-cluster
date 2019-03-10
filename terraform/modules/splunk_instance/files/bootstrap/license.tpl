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

#Allocate elastic IP
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
eip_allocation=$(aws ec2 describe-addresses --filters "Name=tag:host,Values=license" | jq -r '.Addresses[0].AllocationId')
aws ec2 associate-address --allocation-id $eip_allocation --instance-id $instance_id --allow-reassociation
sleep 10
# Wait for an EIP to be allocated and associated by the Controller
ipv4=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
while [[ ! $ipv4 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];do
sleep 2
ipv4=`curl http://169.254.169.254/latest/meta-data/public-ipv4/`
done
echo $ipv4 is the public-ipv4


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

echo "Installing License"
mkdir -p /opt/splunk/etc/licenses/enterprise
aws secretsmanager get-secret-value --secret-id /monitoring/splunk/license --region=eu-west-2 | jq -r '.SecretString' > /opt/splunk/etc/licenses/enterprise/enterprise.lic
chown -R splunk:splunk /opt/splunk/etc/licenses


localIP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
cat <<EOF | sudo -u splunk tee /tmp/dns.json
{
"Comment": "Register master with DNS",
"Changes": [{
"Action": "UPSERT",
"ResourceRecordSet": {
"Name": "${license_address}",
"Type": "A",

"TTL": 90,
"ResourceRecords": [{ "Value": "$localIP"}]
}}]
}
EOF
aws route53 change-resource-record-sets --hosted-zone-id ${private_dns_zone} --change-batch file:///tmp/dns.json


#Generate list of authorised_certs

echo "Creating ma-proxy config directory"
mkdir -p /opt/ma-proxy/

#This is here because the ma-proxy container has dual purpose. This will create an empty file to avoid errors
echo "" > /opt/ma-proxy/authorised_certs

#Generate list of authorised license clients
cat <<EOF | sudo tee /root/get_authorised_lic_certs.sh
#!/bin/bash
/usr/local/bin/aws lambda invoke --function-name get_authorisedcerts /tmp/authorised_lic_certs
cat /tmp/authorised_lic_certs | jq -r '.' > /opt/ma-proxy/authorised_lic_certs
EOF
chmod +x /root/get_authorised_lic_certs.sh
/root/get_authorised_lic_certs.sh

echo "Creating auto-reload cron job for authorised license certificates"
echo "*/5 * * * * /root/get_authorised_lic_certs.sh" | crontab -

#Copy ma-proxy config from S3
aws s3 cp s3://${s3_resources_bucket}/ma-proxy/haproxy.cfg /opt/ma-proxy/haproxy.cfg

echo "Starting MutualAuth Proxy"
docker run -d --restart=unless-stopped \
-v /opt/splunk/etc/auth/customcerts/ca.crt:/certs/cacert.pem \
-v /opt/splunk/etc/auth/customcerts/server_combined.pem:/certs/server-combined.pem \
-v /opt/ma-proxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
-v /opt/ma-proxy/authorised_certs:/etc/haproxy/authorised_certs  \
-v /opt/ma-proxy/authorised_lic_certs:/etc/haproxy/authorised_lic_certs  \
--name ma-proxy \
--net host haproxy

#Get the SplunkCloud CA
openssl s_client -showcerts -verify 5 -connect ${splunkcloud_fwd}:9997 < /dev/null 2> /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print >>"/opt/splunk/etc/auth/customcerts/ca.crt"}'


# Start service and Enable autostart
sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license
sudo systemctl restart Splunkd

