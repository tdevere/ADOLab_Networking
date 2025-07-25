# Private Endpoint Test Lab

> Verify Key Vault connectivity through its private endpoint from the Linux agent VM.

---

## Overview

This exercise validates that the agent VM can resolve and reach the Key Vault over its private endpoint. You will SSH to the agent VM, query the Key Vault for a secret, and confirm the expected output.

## Objectives

- Confirm DNS resolution of the Key Vault FQDN to the private IP
- Retrieve a secret via the private endpoint

## Prerequisites

- Agent environment deployed via Terraform
- The Key Vault contains a secret named `sampleSecret`
- Azure CLI installed on the agent VM

## Steps

### 1. Connect to the Agent VM

SSH to the Linux agent using the key you created during setup:

```bash
ssh -i ~/.ssh/terraform_lab_key azureuser@<agent-public-ip>
```

### 2. Verify DNS Resolution

Ensure the Key Vault FQDN resolves to the private IP returned by Terraform:

```bash
nslookup ${KEY_VAULT_NAME}.vault.azure.net
```

Expected output includes the private IP address, e.g. `10.5.0.4`.

### 3. Query the Key Vault

Authenticate with the Azure CLI and fetch the secret value:

```bash
az login --identity
az keyvault secret show --vault-name $KEY_VAULT_NAME --name sampleSecret \
  --query value -o tsv
```

If successful, the secret value displays on the console.

## Troubleshooting

- **DNS resolves to a public IP** – Check the Private DNS zone link and the VM's DNS settings.
- **Authentication failures** – Ensure the VM's managed identity has at least `Key Vault Secrets User` access.
- **Timeouts or connection refused** – Verify the NSG rules and that the private endpoint is in the correct subnet.

## Cleanup

No resources are created in this exercise, so no cleanup is required.

---
