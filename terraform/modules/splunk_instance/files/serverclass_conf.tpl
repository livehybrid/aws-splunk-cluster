[serverClass:sc_searchhead]
whitelist.0 = *-searchhead-*

[serverClass:sc_indexer]
whitelist.0 = *-indexer-*

[serverClass:sc_license]
whitelist.0 = *-license-*

[serverClass:sc_forwarder]
whitelist.0 = *-fwd-*

[serverClass:sc_license:app:staging_fwd_splunkcloud]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled

[serverClass:sc_heavyforwarder]
whitelist.0 = *-heavy-forwarder-*

[serverClass:sc_indexer:app:staging_idx_receiver]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled

[serverClass:sc_license:app:env_license_pools]
restartSplunkWeb = 0
restartSplunkd = 1
stateOnClient = enabled