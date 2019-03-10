[clustering]
mode = searchhead
master_uri = https://${master_address}:${master_port}
pass4SymmKey = ${pass4SymmKey}
multisite = true


[general]
site = ${site}

#default
pass4SymmKey = ${pass4SymmKey}
#preferred_captain=true for secondary site

#[shclustering]
#pass4SymmKey = ${pass4SymmKey}
#shcluster_label = "shcluster"
##disabled = false
##mgmt_uri = "https://s:${master_port}"
#replication_factor = 2
##conf_deploy_fetch_url = https://${master_address}:${master_port}
##multisite = false
#mode = member #captain

[replication_port://${replication_port}]


[sslConfig]
enableSplunkdSSL = true
#Server SSL Cert
serverCert = /opt/splunk/etc/auth/customcerts/server_combined.pem
sslRootCAPath = /opt/splunk/etc/auth/customcerts/ca.crt

[license]
master_uri = https://${license_address}:${license_port}

[clustermaster:${master_address}:${master_port}]
master_uri = https://${master_address}:${master_port}
multisite = true
pass4SymmKey = ${pass4SymmKey}
site = ${site}