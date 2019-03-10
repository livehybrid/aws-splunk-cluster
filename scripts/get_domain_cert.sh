out_dir=./certs
prefix=$3
domain=$2
profile=$1
output="{\"domain\":\"$domain\"}"
aws lambda invoke --function-name get_sslcert --payload "$output" --profile $profile --region=eu-west-2 /tmp/splunk.json
cat  /tmp/splunk.json | jq -r '.' | jq -r '.crt' > $out_dir/$domain.crt
cat  /tmp/splunk.json | jq -r '.' | jq -r '.key' > $out_dir/$domain.key
echo "Cert saved to $out_dir/$domain.crt"
echo "Key saved to $out_dir/$domain.key"
zip -P Password1 ~/Downloads/$domain.zip $out_dir/$domain.crt $out_dir/$domain.key
