# DNS Failure Lab

> _Simulate DNS misconfiguration and recovery in your lab environment_

---

## Table of Contents
1. [Overview](#overview)
2. [Objectives](#objectives)
3. [Modify the DNS Record](#modify-the-dns-record)
4. [Trigger the Failure](#trigger-the-failure)
5. [Revert the Change](#revert-the-change)
6. [Verification](#verification)
7. [Cleanup](#cleanup)

---

## Overview
This lab demonstrates how an incorrect DNS A record can break connectivity to Azure resources. You will intentionally update the private DNS zone entry for the lab Key Vault, observe the resulting failure in a pipeline or via the Azure CLI, and then restore the correct record.

## Objectives
- Edit the private DNS zone to point the Key Vault name at an invalid IP address.
- Run a pipeline or CLI command to show the failed name resolution.
- Revert the DNS record and confirm successful resolution.

## Modify the DNS Record
1. Log in to the jump box or Cloud Shell with access to the lab subscription.
2. Locate the private DNS zone used for the Key Vault (`privatelink.vaultcore.azure.net`).
3. Find the A record for your Key Vault, e.g. `mylabkv.vaultcore.azure.net`.
4. **Change the IP address** to `203.0.113.10` (an unused test IP).

```bash
# Example using Azure CLI
az network private-dns record-set a update \
  --zone-name privatelink.vaultcore.azure.net \
  --resource-group <rg-name> \
  --name mylabkv \
  --set aRecords[0].ipv4Address="203.0.113.10"
```

## Trigger the Failure
Run a pipeline that retrieves a secret from the Key Vault or test resolution manually:

```bash
# From the agent VM
nslookup mylabkv.vaultcore.azure.net
az keyvault secret show --vault-name mylabkv --name TestSecret
```

Both commands should fail because the FQDN now resolves to the wrong IP.

## Revert the Change
1. Edit the same A record and restore the original private IP address (found in the VM NIC or previous state).
2. Wait a minute for DNS propagation.

```bash
az network private-dns record-set a update \
  --zone-name privatelink.vaultcore.azure.net \
  --resource-group <rg-name> \
  --name mylabkv \
  --set aRecords[0].ipv4Address="<original-ip>"
```

## Verification
- Re-run the pipeline or the `nslookup` and `az keyvault secret show` commands.
- The Key Vault name should resolve correctly and the secret fetch should succeed.

## Cleanup
No additional cleanup is required once the DNS record is restored.
