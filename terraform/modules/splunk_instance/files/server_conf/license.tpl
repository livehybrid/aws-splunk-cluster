[general]
pass4SymmKey = ${pass4SymmKey}

[diskUsage]
minFreeSpace = 3000

[sslConfig]
enableSplunkdSSL = true
#Server SSL Cert
serverCert = /opt/splunk/etc/auth/customcerts/server_combined.pem
sslRootCAPath = /opt/splunk/etc/auth/customcerts/ca.crt