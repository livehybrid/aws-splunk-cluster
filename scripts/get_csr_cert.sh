out_dir=./certs
domain=$(openssl req -in $1 -noout -subject | cut -d '/' -f 6 | cut -d '=' -f 2)
csr=$(cat $1 | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}')
output="{\"domain\":\"$domain\",\"csr\":\"$csr\"}"
aws lambda invoke --function-name get_sslcert --payload "$output" --region=eu-west-2 /tmp/splunk.json
cat  /tmp/splunk.json | jq -r '.' | jq -r '.crt' > $out_dir/$domain.crt
#cat  /tmp/splunk.json | jq -r '.' | jq -r '.key' > $out_dir/$domain.key
echo "Cert saved to $out_dir/$domain.crt"
echo "Key saved to $out_dir/$domain.key"
