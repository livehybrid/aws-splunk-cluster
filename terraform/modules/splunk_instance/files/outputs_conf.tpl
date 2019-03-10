[indexAndForward]
index = false

[indexer_discovery:local]
pass4SymmKey = ${pass4SymmKey}
master_uri = https://${master_address}:${master_port}

[tcpout:default]
indexerDiscovery = local
sslCertPath = /opt/splunk/etc/auth/customcerts/server_combined.pem
sslRootCAPath = /opt/splunk/etc/auth/customcerts/ca.crt