# Testing Azure Key Vault Operations via Azure DevOps Pipeline

This guide explains how to test Azure Key Vault write/read operations using an Azure DevOps YAML pipeline. It includes a complete example pipeline and step-by-step instructions.

## Prerequisites
- Azure DevOps project and repository
- Service connection to Azure (with Key Vault access)
- Key Vault name and resource group
- Pipeline agent with Azure CLI installed

## 1. Create a Service Connection

### If You Are On-Premises: Manual Service Principal & Service Connection Setup

#### 1. Create a Service Principal (Azure CLI)
```powershell
az ad sp create-for-rbac --name "kv-pipeline-sp" --role contributor --scopes /subscriptions/<your-subscription-id>
```
Output will include:
- `appId` (client ID)
- `password` (client secret)
- `tenant` (tenant ID)

#### 2. Grant Key Vault Access Policy
```powershell
az keyvault set-policy --name <your-key-vault-name> --spn <appId> --secret-permissions get list set delete purge
```

#### 3. Create Service Connection in Azure DevOps
1. Go to **Project Settings > Service connections**.
2. Click **New service connection > Azure Resource Manager > Service principal (manual)**.
3. Enter:
   - Subscription ID
   - Subscription name
   - Service principal client ID (`appId`)
   - Service principal key (`password`)
   - Tenant ID (`tenant`)
4. Grant access permission to all pipelines (recommended).
5. Save the service connection and use its name in your pipeline YAML.

---
**Note:** The service principal must have sufficient permissions on the subscription/resource group and Key Vault access policy for secrets.

## 2. Example Pipeline YAML
Create a file named `azure-pipelines.yml` in your repo. The example below includes a purge step to ensure the secret can be recreated reliably:

```yaml
trigger:
- main

pool:
  name: 'SelfHosted'

variables:
  KEYVAULT_NAME: 'lab-kv-1234'

steps:
- task: AzureCLI@2
  displayName: 'Login to Azure'
  inputs:
    azureSubscription: 'SamplesKeyVault'
    scriptType: 'ps'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az account show


# ——— PURGE any lingering soft‑deleted TestSecret ———
- task: AzureCLI@2
  displayName: 'Purge deleted TestSecret if present'
  inputs:
    azureSubscription: 'SamplesKeyVault'
    scriptType: 'ps'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Don’t stop on error
      $ErrorActionPreference = 'Continue'

      az keyvault secret purge `
        --vault-name $env:KEYVAULT_NAME `
        --name TestSecret `
        --only-show-errors

      if ($LASTEXITCODE -ne 0) {
        Write-Host "No soft‑deleted TestSecret to purge"
      } else {
        Write-Host "Purged soft‑deleted TestSecret"
      }

# ——— (Re‑)CREATE the secret ———
- task: AzureCLI@2
  displayName: 'Set secret in Key Vault'
  inputs:
    azureSubscription: 'SamplesKeyVault'
    scriptType: 'ps'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az keyvault secret set `
        --vault-name $env:KEYVAULT_NAME `
        --name 'TestSecret' `
        --value 'MySecretValue'

- task: AzureCLI@2
  displayName: 'Read secret from Key Vault'
  inputs:
    azureSubscription: 'SamplesKeyVault'
    scriptType: 'ps'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az keyvault secret show `
        --vault-name $env:KEYVAULT_NAME `
        --name 'TestSecret' `
        --query value -o tsv

- task: AzureCLI@2
  displayName: 'Delete secret from Key Vault'
  inputs:
    azureSubscription: 'SamplesKeyVault'
    scriptType: 'ps'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az keyvault secret delete `
        --vault-name $env:KEYVAULT_NAME `
        --name 'TestSecret'

```

## 3. How It Works
- The pipeline logs in to Azure using the service connection.
- It purges any lingering soft-deleted secret (if present), sets a secret in the Key Vault, reads it back, and then deletes it.
- All operations use Azure CLI tasks.

## 4. Notes
- Replace `<your-service-connection-name>` with the name of your Azure DevOps service connection.
- Ensure the service principal used by the service connection has Key Vault access policy permissions for secrets, including `purge` if you want to reliably recreate secrets in automation.
- You can add more steps to test other Key Vault operations as needed.

## 5. Troubleshooting
- If you get permission errors, update the Key Vault access policy for your service principal.
- Check the pipeline logs for detailed error messages.

---
For more details, see the official [Azure Key Vault documentation](https://learn.microsoft.com/en-us/azure/key-vault/general/overview) and [Azure DevOps YAML pipelines documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema).
