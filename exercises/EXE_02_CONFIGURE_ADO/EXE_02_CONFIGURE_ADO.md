# Azure DevOps Agent Registration Lab

> _Configure your self‑hosted build agents to join your personal Azure DevOps organization_

---

1. [Overview](#overview)  
2. [Objectives](#objectives)  
3. [Prerequisites](#prerequisites)  
4. [Connect to Your VMs](#connect-to-your-vms)  
5. [Install & Configure the Azure DevOps Agent](#install--configure-the-azure-devops-agent)  
6. [Exercises](#exercises)  
   1. [Exercise 1: Create an Agent Pool](#exercise-1-create-an-agent-pool)  
   2. [Exercise 2: Register the Linux Agent](#exercise-2-register-the-linux-agent)  
   3. [Exercise 3: Register the Windows Agent](#exercise-3-register-the-windows-agent)  
   4. [Exercise 4: Create an ARM Service Connection to Key Vault](#exercise-4-create-an-arm-service-connection-to-key-vault)  
7. [Submission & Verification](#submission--verification)  
8. [Cleanup](#cleanup)  
9. [Further Reading](#further-reading)  

---

## Overview

In this lab you’ll connect to the Linux and Windows VMs you deployed, install the Azure DevOps agent software on each, and register both agents into a new Agent Pool in *your* Azure DevOps organization. You’ll also create an Azure Resource Manager service connection scoped to the lab Key Vault, for pipelines to securely retrieve secrets.

---

## Objectives

- Connect to your self‑hosted VMs (SSH & RDP)  
- Create a new Agent Pool in Azure DevOps  
- Install and configure the agent on Linux and Windows  
- Create an ARM service connection scoped to the lab’s Key Vault  
- Verify both agents and service connection are usable in your pipelines  

---

## Prerequisites

- Completed the Initial Setup Lab (deployed VMs & connectivity infra)  
- An Azure DevOps organization (e.g. `https://dev.azure.com/yourorg`)  
- A Personal Access Token (PAT) with **Agent Pools (read, manage)** and **Service Connections (read, manage)** scopes  
- SSH private key (`~/.ssh/terraform_lab_key_rsa`) for Linux VM  
- RDP client for Windows VM  

---

## Connect to Your VMs

1. **Get the VM public IPs**  
   ```bash
   $LINUX_IP=$(terraform output -raw agent_vm_public_ip)
   $WINDOWS_IP=$(terraform output -raw windows_vm_public_ip)
```

2. **SSH into Linux**

   ```bash
   ssh -i ~/.ssh/terraform_lab_key_rsa azureuser@$LINUX_IP
   ```

3. **RDP into Windows**

   ```powershell
   mstsc /v:$WINDOWS_IP
   ```

   * Username: `azureuser`
   * Password:

     ```bash
     terraform output -raw windows_admin_password
     ```

---

## Install & Configure the Azure DevOps Agent

On **both** VMs you will:

1. Download the agent package
2. Extract it into `~/azagent` (Linux) or `C:\azagent` (Windows)
3. Run the `config` script with your **Organization URL**, **PAT**, and **Agent Pool Name**
4. Install and start the service

---

## Exercises

### Exercise 1: Create an Agent Pool

1. Sign in to your Azure DevOps organization.
2. Go to **Organization Settings → Agent Pools**.
3. Click **Add pool**.
   * Select **Pool type**: `Self-hosted`
   * **Name**: `SelfHostedLabPool`
   * **Type**: Self‑hosted
4. Click **Create**.

---

### Exercise 2: Register the Linux Agent

1. **On your Linux VM** (SSH session), run:

   ```bash
   mkdir ~/azagent && cd ~/azagent
   curl -O https://download.agent.dev.azure.com/agent/2.*.*/vsts-agent-linux-x64-2.*.*.tar.gz (Current Agent Package Version: https://download.agent.dev.azure.com/agent/4.258.1/vsts-agent-linux-x64-4.258.1.tar.gz)
   tar zxvf vsts-agent-linux-x64-*.tar.gz (tar zxvf vsts-agent-linux-x64-4.258.1.tar.gz)
   sudo apt-get update && sudo apt-get install -y libssl1.1 libicu66

   ./config.sh --unattended \
     --url https://dev.azure.com/yourorg \
     --auth pat --token YOUR_PAT \
     --pool SelfHostedLabPool \
     --agent linux-agent-01 \
     --acceptTeeEula

   sudo ./svc.sh install
   sudo ./svc.sh start
   ```
2. **Verify** in Azure DevOps under **Agent Pools → SelfHostedLabPool** that **linux-agent-01** is online.

---

### Exercise 3: Register the Windows Agent

1. **On your Windows VM** (RDP session), open PowerShell as Administrator and run:

   ```powershell
   md C:\azagent; cd C:\azagent
   Invoke-WebRequest -Uri https://download.agent.dev.azure.com/agent/2.*.*/vsts-agent-win-x64-2.*.*.zip -OutFile agent.zip 
   (Current Agent Package Version: https://download.agent.dev.azure.com/agent/4.258.1/vsts-agent-win-x64-4.258.1.zip)
   Expand-Archive .\vsts-agent-win-x64-4.258.1.zip -DestinationPath .

   .\config.cmd --unattended `
     --url https://dev.azure.com/yourorg `
     --auth pat --token YOUR_PAT `
     --pool SelfHostedLabPool `
     --agent windows-agent-01 `
     --acceptTeeEula

   .\svc.sh install
   .\svc.sh start
   ```
2. **Verify** that **windows-agent-01** appears online in **SelfHostedLabPool**.

---

### Exercise 4: Create an ARM Service Connection to Key Vault

1. In Azure DevOps, navigate to your **Project Settings → Service connections**.
2. Click **New service connection** and choose **Azure Resource Manager → Service principal (automatic)**.
3. On the setup form:

   * **Subscription**: select the subscription containing your lab resources
   * **Scope level**: **Resource group**
   * **Resource group**: select your lab’s RG (e.g. `tf-connect-lab-rg`)
   * **Service connection name**: `LabKeyVaultConnection`
   * **Grant access permission to all pipelines**: checked
4. Click **Save**.
5. **Verify** the connection by editing a pipeline and selecting **LabKeyVaultConnection** as the service connection for a Key Vault task.

---

## Submission & Verification

* **Screenshot** of your Agent Pool showing both agents online.
* **Screenshot** of the new **LabKeyVaultConnection** in Service connections.
* **Sample pipeline YAML** snippet demonstrating use of the service connection to fetch a secret.

---

## Cleanup
> Do Not Perform this operation, unless this is the end of your exercises. But failure to remove these resources will impact your Azure budget. When you’re done, you can unregister or simply tear down all Azure resources via Terraform:

```bash
terraform destroy -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -auto-approve
```

---

## Further Reading

* [Configure self-hosted agents](https://docs.microsoft.com/azure/devops/pipelines/agents/v2-linux)
* [Service connections in Azure DevOps](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
* [Azure Key Vault tasks for pipelines](https://docs.microsoft.com/azure/devops/pipelines/tasks/library/azure-key-vault)

