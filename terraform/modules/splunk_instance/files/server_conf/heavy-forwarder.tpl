[general]
site = ${site}
pass4SymmKey = ${pass4SymmKey}

[sslConfig]
enableSplunkdSSL = true
#Server SSL Cert
serverCert = /opt/splunk/etc/auth/customcerts/server_combined.pem
sslRootCAPath = /opt/splunk/etc/auth/customcerts/ca.crt

[license]
master_uri = https://${license_address}:${license_port}

