# NSG Firewall Lab

> Temporarily block outbound access to Azure Key Vault by adding a deny rule to the Network Security Group (NSG) associated with the agent virtual machine. After observing the failed connection, remove the rule to restore access.

## Overview

This exercise demonstrates how an NSG rule can disrupt connectivity to a private endpoint. You will add a deny rule that blocks HTTPS traffic to Key Vault, verify that secret retrieval fails, and then delete the rule.

## Prerequisites

- The Agent & Connectivity lab environment deployed via Terraform
- Azure CLI installed and authenticated

## Steps

### 1. Add the deny rule

```bash
az network nsg rule create \
  --resource-group <agent_rg_name> \
  --nsg-name <agent_nsg_name> \
  --name DenyKeyVault \
  --priority 4096 \
  --direction Outbound \
  --protocol Tcp \
  --destination-address-prefixes AzureKeyVault \
  --destination-port-ranges 443 \
  --access Deny
```

### 2. Test Key Vault access

Attempt to read a secret from Key Vault. The command should fail due to the firewall rule:

```bash
az keyvault secret show --vault-name <kv_name> --name test
```

**Expected output** (truncated):

```
The command failed with an error because the Key Vault endpoint is unreachable.
```

### 3. Remove the rule and re-test

```bash
az network nsg rule delete \
  --resource-group <agent_rg_name> \
  --nsg-name <agent_nsg_name> \
  --name DenyKeyVault

# Retry the secret retrieval
az keyvault secret show --vault-name <kv_name> --name test
```

**Expected output**:

```
You should see the JSON payload for the secret, confirming connectivity is restored.
```

## Cleanup

If you are finished with the lab, remove any remaining deny rule and destroy the environment:

```bash
az network nsg rule delete --resource-group <agent_rg_name> --nsg-name <agent_nsg_name> --name DenyKeyVault
terraform destroy -auto-approve
```
