# Azure DevOps Agent & Connectivity Lab – Initial Setup

> _A hands-on project extending the Azure DevOps Agent & Connectivity environment_

---

1. [Overview](#overview)
2. [Objectives](#objectives)
3. [Prerequisites](#prerequisites)
4. [Generate SSH Key Pair (If Needed)](#generate-ssh-key-pair-if-needed)
5. [Lab Setup](#lab-setup)
6. [Exercises](#exercises)
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
- **Local SSH key pair for agent VM access:**
    - Private key at `~/.ssh/terraform_lab_key`
    - Public key at `~/.ssh/terraform_lab_key.pub`
    *(If you don't have one, follow the instructions in "Generate SSH Key Pair (If Needed)" below before proceeding with Lab Setup.)*

---

### Generate SSH Key Pair (If Needed)

If you don’t yet have an SSH key pair at `~/.ssh/terraform_lab_key_rsa` and `~/.ssh/terraform_lab_key.pub`:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform_lab_key_rsa -N "" -C "terraform lab key RSA"
````

> **Using RSA instead Ed25519?**
>
>   * Only RSA SSH keys are supported by Azure

-----

## Lab Setup

1.  **Clone the repo**

    ```bash
    git clone [https://github.com/YourOrg/terraform-network-lab.git](https://github.com/YourOrg/terraform-network-lab.git)
    cd terraform-network-lab/terraform
    ```

2.  **Populate your variables**

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Ensure admin_ssh_key is NOT present in terraform.tfvars as it will be passed via CLI.
    # The Windows admin password will be automatically generated and outputted by Terraform.
    ```

3.  **Authenticate to Azure**

    ```bash
    az login
    az account set --subscription "<YourSubscriptionID>"
    ```

4.  **Initialize Terraform**

    ```bash
    terraform init
    ```

-----

## Exercises

### Exercise 1: Deploy environments with Terraform

> Do Not Perform this operation, unless you understand the impact to your Azure budget. Remember to remove the lab resources when you are complete.

1.  Create a plan (we’ll override `admin_ssh_key` at plan time):

    ```bash
    terraform plan -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -out=tfplan
    ```

2.  Apply the plan:

    ```bash
    terraform apply "tfplan"
    ```

3.  **Verify**:

      * Outputs for `agent_vm_public_ip`, `key_vault_private_ip`, `private_dns_zone_name`, and **`windows_admin_password`** appear.

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
  terraform refresh -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)"
  ```

  then retry:

  ```bash
  terraform output -raw agent_vm_public_ip
  ```

2. **SSH to the Linux agent**

   ```bash
   ssh -i ~/.ssh/terraform_lab_key_rsa azureuser@$(terraform output -raw agent_vm_public_ip)
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
terraform destroy -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -auto-approve
rm -f terraform.tfstate* terraform.tfstate.backup
```



## Further Reading

  * [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
  * [Azure Private Link & Endpoints](https://learn.microsoft.com/azure/private-link/)
  * [Azure DNS Private Zones](https://learn.microsoft.com/azure/dns/private-zones/)

