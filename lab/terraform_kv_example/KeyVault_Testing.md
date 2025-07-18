# Testing Azure Key Vault: Write/Read Operations from a Remote Client

This guide explains how to test Azure Key Vault access from a remote client, including writing and reading secrets using Azure CLI and PowerShell.

## Prerequisites
- Azure Key Vault deployed (see this lab)
- Key Vault name and resource group
- Azure CLI installed on your client
- Sufficient permissions to access the Key Vault

## 1. Authenticate to Azure
Open a terminal and run:
```powershell
az login
```

## 2. Set Subscription (if needed)
```powershell
az account set --subscription "<your-subscription-id>"
```

## 3. Verify Key Vault Access
List your Key Vaults:
```powershell
az keyvault list --resource-group <your-resource-group>
```

## 4. Write a Secret to Key Vault
```powershell
az keyvault secret set --vault-name <your-key-vault-name> --name "TestSecret" --value "MySecretValue"
```

**Example Output:**
```json
{
  "attributes": {
    "created": "2025-07-18T15:22:28+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoverableDays": 7,
    "recoveryLevel": "CustomizedRecoverable+Purgeable",
    "updated": "2025-07-18T15:22:28+00:00"
  },
  "contentType": null,
  "id": "https://<your-key-vault-name>.vault.azure.net/secrets/TestSecret/<secret-version-id>",
  "kid": null,
  "managed": null,
  "name": "TestSecret",
  "tags": {
    "file-encoding": "utf-8"
  },
  "value": "MySecretValue"
}
```

## 5. Read a Secret from Key Vault
```powershell
az keyvault secret show --vault-name <your-key-vault-name> --name "TestSecret"
```

## 6. Read Secret Value Only
```powershell
az keyvault secret show --vault-name <your-key-vault-name> --name "TestSecret" --query value -o tsv
```

## 7. PowerShell Example
```powershell
# Login
Connect-AzAccount

# Set context (if needed)
Set-AzContext -SubscriptionId <your-subscription-id>

# Write secret
Set-AzKeyVaultSecret -VaultName <your-key-vault-name> -Name "TestSecret" -SecretValue (ConvertTo-SecureString "MySecretValue" -AsPlainText -Force)

# Read secret
(Get-AzKeyVaultSecret -VaultName <your-key-vault-name> -Name "TestSecret").SecretValueText
```

## 8. Troubleshooting
### Access Denied: Secrets Permission
If you see an error like:
```
Forbidden: does not have secrets set permission on key vault
```
You need to grant your user/service principal access to the Key Vault:

1. Find your Azure AD user object ID:
   ```powershell
   az ad signed-in-user show --query id -o tsv
   ```
2. Grant access policy for secrets:
   ```powershell
   az keyvault set-policy --name <your-key-vault-name> --object-id <your-object-id> --secret-permissions get list set delete
   ```
3. Retry your secret operation.

- Ensure your client IP is allowed by Key Vault firewall/network rules
- Ensure your user/service principal has Key Vault access policies
- Use `az keyvault show --name <your-key-vault-name>` to verify configuration

## 9. Clean Up
To delete the test secret:
```powershell
az keyvault secret delete --vault-name <your-key-vault-name> --name "TestSecret"
```

**Example Output:**
```json
{
  "attributes": {
    "created": "2025-07-18T15:22:28+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoverableDays": 7,
    "recoveryLevel": "CustomizedRecoverable+Purgeable",
    "updated": "2025-07-18T15:22:28+00:00"
  },
  "contentType": null,
  "deletedDate": "2025-07-18T15:23:14+00:00",
  "id": "https://<your-key-vault-name>.vault.azure.net/secrets/TestSecret/<secret-version-id>",
  "kid": null,
  "managed": null,
  "name": "TestSecret",
  "recoveryId": "https://<your-key-vault-name>.vault.azure.net/deletedsecrets/TestSecret",
  "scheduledPurgeDate": "2025-07-25T15:23:14+00:00",
  "tags": {
    "file-encoding": "utf-8"
  },
  "value": null
}
```

> **Note:** If soft-delete protection is enabled, the secret will be moved to a soft-deleted state. You cannot create a secret with the same name until it is purged. See [Azure Key Vault soft-delete documentation](https://learn.microsoft.com/azure/key-vault/general/soft-delete-overview) for details.

---
For more details, see the official [Azure Key Vault documentation](https://learn.microsoft.com/en-us/azure/key-vault/general/overview).
