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
cat <<EOF | sudo -u splunk tee /opt/splunk/etc/system/local/outputs.conf
${outputs_conf_content}
EOF
chown -R splunk: /opt/splunk


# Update hostname
INSTANCE_ID=$(ec2metadata --instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region=$REGION --output=text | cut -f5)

hostname $${INSTANCE_NAME//_/-}
echo `hostname` > /etc/hostname
sed -i 's/localhost$/localhost '`hostname`' '`hostname`'.${fqdn}/' /etc/hosts

mkdir -p /opt/splunk/etc/auth/customcerts/
echo "Generating SSL Key/Cert"
aws lambda invoke --function-name get_sslcert --payload "{\"domain\":\"$(hostname).${fqdn}\"}" /tmp/certs.json
cat  /tmp/certs.json | jq -r '.' | jq -r '.crt' > /opt/splunk/etc/auth/customcerts/server.crt
cat  /tmp/certs.json | jq -r '.' | jq -r '.key' > /opt/splunk/etc/auth/customcerts/server.key

#Get CA crt
aws s3 cp s3://${s3_pki_bucket}/ca/${ca_name}.crt /opt/splunk/etc/auth/customcerts/ca.crt

cat /opt/splunk/etc/auth/customcerts/server.crt /opt/splunk/etc/auth/customcerts/server.key /opt/splunk/etc/auth/customcerts/ca.crt > /opt/splunk/etc/auth/customcerts/server_combined.pem
chown -R splunk:splunk /opt/splunk/etc/auth/customcerts/



# Enable autostart
sudo /opt/splunk/bin/splunk enable boot-start -user splunk --accept-license


SPLUNK_ADMIN_PASS=`aws secretsmanager get-secret-value --secret-id /monitoring/splunk/password --region=eu-west-2 | jq -r '.SecretString'`
SH_IP_CMD=`aws ec2 describe-instances \
--filters Name=tag:Name,Values=splunk_searchhead* \
Name=instance-state-name,Values=running \
--region=eu-west-2 \
--query Reservations[*].Instances[*].[NetworkInterfaces[*].PrivateIpAddresses[*].PrivateIpAddress]`

# Get IP addresses and set up variables
PRIVATE_IP_ADDR=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
SH_IP_ADDRS=`echo $SH_IP_CMD | jq -j 'flatten|sort'`
SH_HTTPS=`echo $SH_IP_ADDRS | jq -j '["https://\(.[]):8089"]|join(",")'`
SH_CAPTAIN_IP_ADDR=`echo $SH_IP_ADDRS | jq -r '.[1]'`
SH_IP_BARE=`echo $SH_IP_ADDRS | jq -r ".[]"`

# Add instance to the search head cluster
sudo systemctl restart Splunkd
#-site site1

#Wait for localhost to come up
TESTCMD="nc -n -w5 127.0.0.1 8089"
let TESTRESULT=1
while [ $TESTRESULT -ne 0 ]; do
`$TESTCMD`
let TESTRESULT=$?
done
printf "UP\n"

sudo -u splunk -i /opt/splunk/bin/splunk init shcluster-config -mode searchhead -auth "${splunk_admin_username}:$SPLUNK_ADMIN_PASS" -mgmt_uri https://$PRIVATE_IP_ADDR:8089 -replication_port ${replication_port} -replication_factor 2 -conf_deploy_fetch_url https://${master_address}:${master_port} -secret ${pass4SymmKey} -shcluster_label shcluster
sudo systemctl restart Splunkd

# Only make one of the instances a captain
if [ "$PRIVATE_IP_ADDR" == "$SH_CAPTAIN_IP_ADDR" ]; then
    # Test that all cluster instances are up before continuing
    for ip in $SH_IP_BARE; do
    printf "Testing $ip..."
    TESTCMD="nc -n -w5 $ip 8089"
    let TESTRESULT=1
    while [ $TESTRESULT -ne 0 ]; do
    `$TESTCMD`
    let TESTRESULT=$?
    done
    printf "UP\n"
    done
    sleep 60
    sudo -u splunk -i /opt/splunk/bin/splunk bootstrap shcluster-captain -servers_list "$SH_HTTPS" -auth "${splunk_admin_username}:$SPLUNK_ADMIN_PASS"
fi

sudo systemctl restart Splunkd



echo "Initialise oauth proxy"
docker run -d --restart=unless-stopped \
    -v /opt/splunk/etc/auth/customcerts/ca.crt:/etc/ssl/certs/ca-certificates.crt \
    -v /opt/splunk/etc/auth/customcerts:/certs \
    --network=host --name oauth2 -it starefossen/oauth2-proxy \
    -upstream=https://$(hostname).${fqdn}:8000 \
    -tls-cert=/certs/server.crt \
    -tls-key=/certs/server.key \
    -https-address=0.0.0.0:8443 \
    -login-url="https://${oauth_server}/oauth/authorize" \
    -redeem-url="https://${oauth_server}/oauth/token" \
    -validate-url="https://${oauth_server}/api/v4/user" \
    -client-id=${oauth_clientid} \
    -client-secret=${oauth_clientsecret} \
    -email-domain=* -cookie-secret=blah -redirect-url=https://search.${fqdn}/oauth2/callback \
    -scope=api -ssl-insecure-skip-verify=true -cookie-secure=true -provider=gitlab

