# Azure DevOps Agent & Connectivity Lab – Initial Setup

> _A hands-on project extending the Azure DevOps Agent & Connectivity environment_

---

1. [Overview](#overview)
2. [Objectives](#objectives)
3. [Prerequisites](#prerequisites)
4. [Generate SSH Key Pair (If Needed)](#generate-ssh-key-pair-if-needed)
5. [Lab Setup](#lab-setup)
6. [Exercises](#exercises)
    1. [Exercise 1: Deploy environments with Terraform](#exercise-1-deploy-environments-with-Terraform)
    2. [Exercise 2: Validate agent VM access](#exercise-2-validate-agent-VM-access)
7. [Submission & Verification](#submission--verification)
8. [Cleanup](#cleanup)
9. [Further Reading](#further-reading)

---

## Overview

This guide automates the deployment of the **Agent** and **Connectivity** environments using Terraform. You’ll spin up a self-hosted Linux & Windows build agent, a Key Vault with a private endpoint, and a Private DNS zone configured to simulate DNS failures. These exercises focus on deployment and basic connectivity validation.

---

## Objectives

- Deploy the Agent and Connectivity environments with a single Terraform project
- Validate SSH (Linux) and RDP (Windows) access to the agent VMs

---


## Prerequisites

- Completed the Azure DevOps Agent & Connectivity Lab
- Azure subscription with **Contributor** role
- Terraform CLI $\ge$ 1.4.0 installed
- Azure CLI or PowerShell Az modules

---

## Lab Setup

### 1. Prepare Your Lab Directory

Create a dedicated directory off your root drive (e.g. `C:\ADOLab_Networking`) to store all lab files and cloned content:

```powershell
New-Item -ItemType Directory -Path C:\ADOLab_Networking
```

### 2. Generate SSH Key Pair (Precondition)

You must have a local SSH key pair for agent VM access:
- Private key at `~/.ssh/terraform_lab_key`
- Public key at `~/.ssh/terraform_lab_key.pub`


If you don’t yet have an SSH key pair at these locations, generate one. Use the following command in your preferred shell:





**For PowerShell (Windows):**
```powershell
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\terraform_lab_key
```

> If you see a message like `already exists`, you already have a key at that location. You can:
> - Press `y` to overwrite (this will replace your existing key—only do this if you do not need the old key).
> - Press `n` to cancel and use your existing key.
> - Or specify a different filename if you want to keep both keys.

> **Important:** Save your SSH key passphrase somewhere secure—you will need it later in the lab to access your VMs.

**For WSL or Git Bash:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform_lab_key -N ""
```

> **Note:** Only RSA SSH keys are supported by Azure (not Ed25519).

---

### 3. Clone the Repo Into Your Lab Directory


Copy the repository into your new lab directory:

```powershell
git clone https://github.com/tdevere/ADOLab_Networking.git
cd C:\ADOLab_Networking\lab\terraform
```


4.  **Populate your variables**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Ensure admin_ssh_key is NOT present in terraform.tfvars as it will be passed via CLI.
    # The Windows admin password will be automatically generated and outputted by Terraform.
    ```


5.  **Authenticate to Azure**

    ```bash
    az login #Subscription Id obtained here
    az account set --subscription "<YourSubscriptionID>"
    ```


6.  **Initialize Terraform**

    ```bash
    terraform init
    ```

-----

### Exercise 1: Deploy environments with Terraform

> Do Not Perform this operation, unless you understand the impact to your Azure budget. Remember to remove the lab resources when you are complete.

1.  Create a plan (we’ll override `admin_ssh_key` at plan time):

    ```bash
    terraform plan -var="admin_password=<provide_your_windows_admin_password>" -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -out=tfplan
    ```

2.  Apply the plan:

    ```bash
    terraform apply "tfplan"
    ```

3.  **Verify**:

      * Outputs for `agent_vm_public_ip`,`windows_vm_public_ip`, `key_vault_private_ip`, `private_dns_zone_name`, and **`windows_admin_password`** appear.

> **Why pass via `-var`?**
>
>   * Keeps your public key out of version control
>   * Makes automation easier (CI/CD pipelines can inject secrets at runtime)
>   * Ensures Terraform picks up the latest key without editing files

-----

### Exercise 2: Validate agent VM access

  * **Linux agent**

1. **Check the Linux agent public IP**  

  ```bash
   terraform output -raw agent_vm_public_ip
  ```

* If you see a valid IP (e.g. `52.x.y.z`), proceed to step 2.
* If it’s blank, run:

  ```bash
  terraform refresh -var="admin_password=<provide_your_windows_admin_password>" -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)"
  ```

  then retry:

  ```bash
  terraform output -raw agent_vm_public_ip
  ```

2. **SSH to the Linux agent**

   ```bash
   ssh -i ~/.ssh/terraform_lab_key azureuser@$(terraform output -raw agent_vm_public_ip)
   ```

   *Verify*: You land at a shell prompt without entering a password.

3. **RDP to the Windows agent**

   ```powershell
   mstsc /v:$(terraform output -raw agent_vm_public_ip)
   ```

   * Username: `azureuser` (or your `admin_username`)
   * Password:

     ```bash
     terraform output -raw windows_admin_password
     ```

   *Verify*: You see the Windows desktop.


## Submission & Verification

  * Include your **Terraform outputs**.
  * Attach a terminal log of a successful SSH session.
  * Attach a screenshot of a successful RDP session.



## Cleanup

> Do Not Perform this operation, unless this is the end of your exercises. But failure to remove these resources will impact your Azure budget.

```bash
terraform destroy -var="admin_password=<provide_your_windows_admin_password>" -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -auto-approve
rm -f terraform.tfstate* terraform.tfstate.backup
```

## Troubleshooting: Key Vault Name Already Exists

If you encounter an error like:

```
Error: creating Key Vault ... Code="VaultAlreadyExists" Message="The vault name 'lab-kv-1234' is already in use. Vault names are globally unique ..."
```

**Resolution:**

- Azure Key Vault names must be globally unique across all Azure subscriptions and regions.
- If the name is already taken, update your Key Vault name in your Terraform variables (e.g., add a random suffix or use a unique identifier).
- If you recently deleted a Key Vault with this name, it may be in a recoverable (soft deleted) state. You must purge it before reusing the name:

  1. Find the deleted vault:
     ```bash
     az keyvault list-deleted --location <region>
     ```
  2. Purge the deleted vault:
     ```bash
     az keyvault purge --name <your-vault-name>
     ```

See official docs for more: [Azure Key Vault soft-delete and purge](https://go.microsoft.com/fwlink/?linkid=2147740)

## Further Reading

  * [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
  * [Azure Private Link & Endpoints](https://learn.microsoft.com/azure/private-link/)
  * [Azure DNS Private Zones](https://learn.microsoft.com/azure/dns/private-zones/)

