[general]
site = ${site}
pass4SymmKey = ${pass4SymmKey}

[shclustering]
pass4SymmKey = ${pass4SymmKey}
shcluster_label = "shcluster"


[diskUsage]
minFreeSpace = 3000

[sslConfig]
enableSplunkdSSL = true
#Server SSL Cert
serverCert = /opt/splunk/etc/auth/customcerts/server_combined.pem
sslRootCAPath = /opt/splunk/etc/auth/customcerts/ca.crt


[lmpool:auto_generated_pool_enterprise]
description = auto_generated_pool_enterprise
quota = 10485760000
slaves = *
stack_id = enterprise

[license]
master_uri = https://${license_address}:${license_port}

[indexer_discovery]
pass4SymmKey = ${pass4SymmKey}
#polling_rate =
#indexerWeightByDiskCapacity = <bool>

${additional_config}