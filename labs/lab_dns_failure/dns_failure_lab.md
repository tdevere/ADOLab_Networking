# DNS Failure Lab

> _Simulate DNS misconfiguration and recovery in your lab environment_

---

## Table of Contents
1. [Overview](#overview)
2. [Objectives](#objectives)
3. [Apply the DNS Misconfiguration](#apply-the-dns-misconfiguration)
4. [Trigger the Failure](#trigger-the-failure)
5. [Revert the Change](#revert-the-change)
6. [Verification](#verification)
7. [Cleanup](#cleanup)

---

## Overview
This lab demonstrates how an incorrect DNS A record can break connectivity to Azure resources. The failure is introduced via **Terraform**, so you can reproduce and roll back the issue consistently without manual portal changes.

## Objectives
- Edit the private DNS zone to point the Key Vault name at an invalid IP address.
- Run a pipeline or CLI command to show the failed name resolution.
- Revert the DNS record and confirm successful resolution.

## Apply the DNS Misconfiguration
1. From the `labs/base_lab` directory run `terraform init` if you haven't already.
2. Create a scenario file named `scenario_dns_failure.tfvars` with the following content:

   ```hcl
   lab_scenario = "dns_failure"
   wrong_kv_ip  = "203.0.113.10"
   ```

3. Plan and apply the change:

   ```bash
   terraform plan -var-file="scenario_dns_failure.tfvars" -out=tfplan
   terraform apply tfplan
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
1. Update `scenario_dns_failure.tfvars` so that `wrong_kv_ip` matches the correct IP returned by `terraform output -raw key_vault_private_ip`.
2. Reapply Terraform to restore the working configuration:

```bash
terraform plan -var-file="scenario_dns_failure.tfvars" -out=tfplan
terraform apply tfplan
```

## Verification
- Re-run the pipeline or the `nslookup` and `az keyvault secret show` commands.
- The Key Vault name should resolve correctly and the secret fetch should succeed.

## Cleanup
No additional cleanup is required once the DNS record is restored.
