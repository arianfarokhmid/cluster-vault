# Vault High Availability Setup with Ansible

This repository contains Ansible playbooks and roles for deploying and configuring HashiCorp Vault in a High Availability (HA) mode using Raft storage. 

## Prerequisites

### 1. Generate SSL Certificates
Vault requires secure communication between nodes. Generate a self-signed SSL certificate using `openssl`. A configuration file (`cert.conf`) is provided in the root of the project.

Run the following command to create the certificates:

```bash
openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout selfsigned.key -out selfsigned.crt -config cert.conf -days 9999
```

Place the generated `selfsigned.key` and `selfsigned.crt` files in the designated ansible/ssl.

---

### 2. Update the Inventory File
Modify the `inventory.ini` file to include the IP addresses or hostnames of your Vault nodes. An example structure:

```ini
[vault]
node1 ansible_host=192.168.1.101
node2 ansible_host=192.168.1.102
node3 ansible_host=192.168.1.103
```

---

## Running the Playbook

Use the following command to execute the Ansible playbook and deploy Vault:

```bash
ansible-playbook -i inventory.ini vault.yml
```

---

## Post-Deployment Steps

### 1. Check Vault Status
After deployment, verify that Vault is running on all nodes by running:

```bash
vault status
```

---

### 2. Initialize Vault (Node 1 Only)
Run the initialization command on **Vault Node 1** only. This will generate the unseal keys and initial root token. Store these values securely, as they are required for unsealing and administrative tasks.

```bash
vault operator init -key-shares=1 -key-threshold=1
```

---

### 3. Set Vault Token Environment Variable
Export the initial root token to the environment for easy authentication. Replace `<initial-root-token>` with the value from the previous step.

```bash
export VAULT_TOKEN=<initial-root-token>
echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /root/.bash_profile
```

---

### 4. Unseal Vault
Unseal Vault on **all nodes** using the unseal key generated during initialization. This process is required to activate the Vault server.

```bash
vault operator unseal <your-seal-key>
```

Repeat this step on the other two nodes. Observe the **Unseal Progress** key in the output as you present the key on each node. Once the threshold is met, the `Sealed` status changes from `true` to `false`.

---

### 5. Check Cluster Raft Status
Verify the Raft cluster status by running the following command:

```bash
vault operator raft list-peers
```

This command lists all the nodes in the Raft cluster and their status.

---

## Testing the High Availability Setup

1. Write a secret to Vault using either the active or standby instance. Verify that the secret is replicated across the cluster:

   ```bash
   vault kv put secret/my-secret key="value"
   vault kv get secret/my-secret
   ```

2. Simulate a failure by stopping the active Vault instance:

   ```bash
   sudo systemctl stop vault
   ```

3. Check the Raft cluster status again to confirm that a standby instance has assumed leadership:

   ```bash
   vault operator raft list-peers
   ```

---

## Conclusion

Your Vault cluster is now operational in High Availability mode. The setup ensures seamless request forwarding and leadership failover. Test the configuration by writing and reading secrets, as well as simulating a system failure to observe the cluster's resilience.

For further information, consult the [Vault Documentation](https://www.vaultproject.io/docs/).
