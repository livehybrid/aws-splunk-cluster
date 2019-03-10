[clustering]
mode = master
replication_factor = ${replication_factor}
search_factor = ${search_factor}
pass4SymmKey = ${pass4SymmKey}

multisite = true
available_sites = site1
#,site2
site_replication_factor = origin:${replication_factor}, total:${replication_factor}
site_search_factor = origin:${search_factor}, total:${search_factor}