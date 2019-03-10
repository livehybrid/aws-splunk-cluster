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

#Mount the hot disk
#mkdir -p /data/hot;
#mount /dev/xvdh /data/hot;
INSTANCE_ID=$(ec2metadata --instance-id)
echo "Attach cold volume"
COLD_VOL=`aws ec2 describe-volumes --filters Name=tag:Name,Values=$(hostname)-cold --query "Volumes[*].{ID:VolumeId}" | jq -r '.[0]["ID"]'`
aws ec2 attach-volume --volume-id $COLD_VOL --instance-id $INSTANCE_ID --device /dev/sdf

echo "Attach Hot volume"
COLD_VOL=`aws ec2 describe-volumes --filters Name=tag:Name,Values=$(hostname)-hot --query "Volumes[*].{ID:VolumeId}" | jq -r '.[0]["ID"]'`
aws ec2 attach-volume --volume-id $COLD_VOL --instance-id $INSTANCE_ID --device /dev/sdf

#TODO Check for attachment
#TODO Check is formatted
#TODO Mount

#TODO - Mount other disks

# Start service and Enable autostart
sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license
sudo systemctl restart Splunkd
