### Node 2 ###
storage "raft" {
    path = "/opt/raft"
    node_id = "node2"
    retry_join
    {
        leader_api_addr = "https://192.168.7.36:8200"
        leader_client_cert_file = "/etc/vault.d/tls/selfsigned.crt"
        leader_client_key_file = "/etc/vault.d/tls/selfsigned.key"
    }
    retry_join
    {
        leader_api_addr = "https://192.168.7.38:8200"
        leader_client_cert_file = "/etc/vault.d/tls/selfsigned.crt"
        leader_client_key_file = "/etc/vault.d/tls/selfsigned.key"
    }
}

listener "tcp" {
   address = "0.0.0.0:8200"
   tls_disable = false
   tls_cert_file = "/etc/vault.d/tls/selfsigned.crt"
   tls_key_file = "/etc/vault.d/tls/selfsigned.key"
   tls_require_and_verify_client_cert = 0
}

api_addr = "https://192.168.7.37:8200"
cluster_addr = "https://192.168.7.37:8201"
disable_mlock = true
ui = true
log_level = "trace"
disable_cache = true
cluster_name = "beroozresaan-local"