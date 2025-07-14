
# Azure DevOps Agent Registration Lab

> _Configure your self‑hosted build agents to join your personal Azure DevOps organization_

---

1. [Overview](#overview)  
2. [Objectives](#objectives)  
3. [Prerequisites](#prerequisites)  
4. [Connect to Your VMs](#connect-to-your-vms)  
5. [Install & Configure the Azure DevOps Agent](#install--configure-the-azure-devops-agent)  
6. [Exercises](#exercises)  
   1. [Create an Agent Pool](#exercise-1-create-an-agent-pool)  
   2. [Register the Linux Agent](#exercise-2-register-the-linux-agent)  
   3. [Register the Windows Agent](#exercise-3-register-the-windows-agent)  
7. [Submission & Verification](#submission--verification)  
8. [Cleanup](#cleanup)  
9. [Further Reading](#further-reading)  

---

## Overview

In this lab you’ll connect to the Linux and Windows VMs you deployed, install the Azure DevOps agent software on each, and register both agents into a new Agent Pool in *your* Azure DevOps organization.

---

## Objectives

- Connect to your self‑hosted VMs (SSH & RDP)  
- Create a new Agent Pool in Azure DevOps  
- Install and configure the agent on Linux and Windows via unattended scripts  
- Verify each agent appears online in your pool  

---

## Prerequisites

- Completed the Initial Setup Lab (deployed VMs & connectivity infra)  
- An Azure DevOps organization (e.g. `https://dev.azure.com/yourorg`)  
- A Personal Access Token (PAT) with **Agent Pools (read, manage)** and **Deployment Group (read, manage)** scopes  
- SSH private key (`~/.ssh/terraform_lab_key_rsa`) for Linux VM  
- RDP client for Windows VM  

---

## Connect to Your VMs

1. **Get the VM public IPs**  
   ```bash
   LINUX_IP=$(terraform output -raw agent_vm_public_ip)
   WINDOWS_IP=$LINUX_IP   # same output for this demo
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
2. Go to **Organization Settings → Agent Pools**.
3. Click **New pool**.

   * **Name**: `SelfHostedLabPool`
   * **Type**: Self‑hosted
4. Click **Create**.

> Remember this exact name for the agent configuration steps below.

---

### Exercise 2: Register the Linux Agent

1. **On your Linux VM** (SSH session), run:

   ```bash
   # Create a directory and navigate
   mkdir ~/azagent && cd ~/azagent

   # Download the latest Linux x64 agent
   curl -O https://vstsagentpackage.azureedge.net/agent/2.**.**/vsts-agent-linux-x64-2.**.**.tar.gz

   # Extract
   tar zxvf vsts-agent-linux-x64-2.*.tar.gz

   # Install dependencies (Ubuntu/Debian)
   sudo apt-get update && sudo apt-get install -y libssl1.1 libicu66

   # Configure agent (replace placeholders)
   ./config.sh --unattended \
     --url https://dev.azure.com/yourorg \
     --auth pat --token YOUR_PAT \
     --pool SelfHostedLabPool \
     --agent linux-agent-01 \
     --acceptTeeEula

   # Install & start as systemd service
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

2. **Verify** in Azure DevOps under **Agent Pools → SelfHostedLabPool** that **linux-agent-01** is online.

---

### Exercise 3: Register the Windows Agent

1. **On your Windows VM** (RDP session), open PowerShell as Administrator and run:

   ```powershell
   # Create folder
   md C:\azagent; cd C:\azagent

   # Download the Windows agent
   Invoke-WebRequest -Uri https://vstsagentpackage.azureedge.net/agent/2.**.**/vsts-agent-win-x64-2.**.**.zip -OutFile agent.zip

   # Extract
   Expand-Archive .\agent.zip -DestinationPath .

   # Configure agent (replace placeholders)
   .\config.cmd --unattended `
     --url https://dev.azure.com/yourorg `
     --auth pat --token YOUR_PAT `
     --pool SelfHostedLabPool `
     --agent windows-agent-01 `
     --acceptTeeEula

   # Install & start as Windows service
   .\svc.sh install
   .\svc.sh start
   ```

2. **Verify** that **windows-agent-01** appears online in **SelfHostedLabPool**.

---

## Submission & Verification

* **Screenshot** of your Agent Pool showing both agents online.
* **Logs** from each VM’s `svc.sh status` confirming the service is running.

---

## Cleanup

> When you’re done, you can unregister or simply tear down all Azure resources via Terraform:

```bash
terraform destroy -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -auto-approve
```

---

## Further Reading

* [Configure self-hosted agents](https://docs.microsoft.com/azure/devops/pipelines/agents/v2-linux)
* [Agent pools and agent capabilities](https://docs.microsoft.com/azure/devops/pipelines/agents/pools-queues)
* [Personal Access Tokens (PATs)](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)


# Azure DevOps Agent Registration Lab

> _Configure your self‑hosted build agents to join your personal Azure DevOps organization_

---

1. [Overview](#overview)  
2. [Objectives](#objectives)  
3. [Prerequisites](#prerequisites)  
4. [Connect to Your VMs](#connect-to-your-vms)  
5. [Install & Configure the Azure DevOps Agent](#install--configure-the-azure-devops-agent)  
6. [Exercises](#exercises)  
   1. [Create an Agent Pool](#exercise-1-create-an-agent-pool)  
   2. [Register the Linux Agent](#exercise-2-register-the-linux-agent)  
   3. [Register the Windows Agent](#exercise-3-register-the-windows-agent)  
7. [Submission & Verification](#submission--verification)  
8. [Cleanup](#cleanup)  
9. [Further Reading](#further-reading)  

---

## Overview

In this lab you’ll connect to the Linux and Windows VMs you deployed, install the Azure DevOps agent software on each, and register both agents into a new Agent Pool in *your* Azure DevOps organization.

---

## Objectives

- Connect to your self‑hosted VMs (SSH & RDP)  
- Create a new Agent Pool in Azure DevOps  
- Install and configure the agent on Linux and Windows via unattended scripts  
- Verify each agent appears online in your pool  

---

## Prerequisites

- Completed the Initial Setup Lab (deployed VMs & connectivity infra)  
- An Azure DevOps organization (e.g. `https://dev.azure.com/yourorg`)  
- A Personal Access Token (PAT) with **Agent Pools (read, manage)** and **Deployment Group (read, manage)** scopes  
- SSH private key (`~/.ssh/terraform_lab_key_rsa`) for Linux VM  
- RDP client for Windows VM  

---

## Connect to Your VMs

1. **Get the VM public IPs**  
   ```bash
   LINUX_IP=$(terraform output -raw agent_vm_public_ip)
   WINDOWS_IP=$LINUX_IP   # same output for this demo
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
2. Go to **Organization Settings → Agent Pools**.
3. Click **New pool**.

   * **Name**: `SelfHostedLabPool`
   * **Type**: Self‑hosted
4. Click **Create**.

> Remember this exact name for the agent configuration steps below.

---

### Exercise 2: Register the Linux Agent

1. **On your Linux VM** (SSH session), run:

   ```bash
   # Create a directory and navigate
   mkdir ~/azagent && cd ~/azagent

   # Download the latest Linux x64 agent
   curl -O https://vstsagentpackage.azureedge.net/agent/2.**.**/vsts-agent-linux-x64-2.**.**.tar.gz

   # Extract
   tar zxvf vsts-agent-linux-x64-2.*.tar.gz

   # Install dependencies (Ubuntu/Debian)
   sudo apt-get update && sudo apt-get install -y libssl1.1 libicu66

   # Configure agent (replace placeholders)
   ./config.sh --unattended \
     --url https://dev.azure.com/yourorg \
     --auth pat --token YOUR_PAT \
     --pool SelfHostedLabPool \
     --agent linux-agent-01 \
     --acceptTeeEula

   # Install & start as systemd service
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

2. **Verify** in Azure DevOps under **Agent Pools → SelfHostedLabPool** that **linux-agent-01** is online.

---

### Exercise 3: Register the Windows Agent

1. **On your Windows VM** (RDP session), open PowerShell as Administrator and run:

   ```powershell
   # Create folder
   md C:\azagent; cd C:\azagent

   # Download the Windows agent
   Invoke-WebRequest -Uri https://vstsagentpackage.azureedge.net/agent/2.**.**/vsts-agent-win-x64-2.**.**.zip -OutFile agent.zip

   # Extract
   Expand-Archive .\agent.zip -DestinationPath .

   # Configure agent (replace placeholders)
   .\config.cmd --unattended `
     --url https://dev.azure.com/yourorg `
     --auth pat --token YOUR_PAT `
     --pool SelfHostedLabPool `
     --agent windows-agent-01 `
     --acceptTeeEula

   # Install & start as Windows service
   .\svc.sh install
   .\svc.sh start
   ```

2. **Verify** that **windows-agent-01** appears online in **SelfHostedLabPool**.

---

## Submission & Verification

* **Screenshot** of your Agent Pool showing both agents online.
* **Logs** from each VM’s `svc.sh status` confirming the service is running.

---

## Cleanup

> Do Not Perform this operation, unless this is the end of your exercises. But failure to remove these resources will impact your Azure budget. When you’re done, you can unregister or simply tear down all Azure resources via Terraform:

```bash
terraform destroy -var="admin_ssh_key=$(cat ~/.ssh/terraform_lab_key.pub)" -auto-approve
```

---

## Further Reading

* [Configure self-hosted agents](https://docs.microsoft.com/azure/devops/pipelines/agents/v2-linux)
* [Agent pools and agent capabilities](https://docs.microsoft.com/azure/devops/pipelines/agents/pools-queues)
* [Personal Access Tokens (PATs)](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

