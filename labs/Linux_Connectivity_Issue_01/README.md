# Lab: Linux Connectivity Issue 01

## Scenario

You are a DevOps support engineer. The Linux build agent is unreachable due to a missing public IP. Your job is to troubleshoot and resolve the connectivity issue using Azure tools (Portal or CLI). **Do not use Terraform to fix the problem.**

---

## How to Run This Scenario

1. **Navigate to the base lab folder:**
   ```powershell
   cd ../base_lab
   ```
2. **Initialize Terraform:**
   ```powershell
   terraform init
   ```
3. **Plan and apply with scenario variables:**
   ```powershell
   $sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub
   terraform plan -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
   terraform apply tfplan
   ```

This will provision the environment with the public IP for the Linux agent disabled, simulating the connectivity issue.

---

## Troubleshooting Tasks

1. Attempt to SSH to the agent using the public IP (should fail).
2. Check the VM's networking configuration in the Azure Portal.
3. Use Azure CLI or Portal to verify if the public IP is attached and enabled.
4. Re-enable or re-attach the public IP using Azure Portal or CLI.
5. Confirm the agent is reachable via SSH and appears online in the DevOps agent pool.
6. Document your troubleshooting steps and resolution.

---

## Notes
- Do not use Terraform to fix the issue. The lab simulates a real-world operational scenario.
- If you need to roll back, contact your instructor or use provided rollback instructions.

# Lab: Linux Connectivity Issue 01

## Scenario

You are a DevOps support engineer. A build pipeline is failing because the Linux build agent is unreachable. The environment was provisioned for you—your job is to troubleshoot and resolve the connectivity issue using Azure tools (Portal or CLI). **Do not use Terraform to fix the problem.**

---

## Lab Setup

Follow these steps to set up your lab environment:

1. **Clone the repository and navigate to the base lab folder:**
   ```powershell
   git clone https://github.com/tdevere/ADOLab_Networking.git
   cd ADOLab_Networking/labs/base_lab
   ```
2. **Initialize Terraform:**
   ```powershell
   terraform init
   ```
3. **Plan and apply with scenario variables:**
   ```powershell
   $sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub
   terraform plan -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
   terraform apply tfplan
   ```
4. **Obtain the Linux agent VM details:**
   - Use the Azure Portal or CLI to find the VM and its networking configuration.

---

## Symptoms

- Azure DevOps pipeline fails with error:
  > Agent unreachable: SSH connection timed out
- You cannot SSH to the Linux agent using its public IP.
- The agent does not appear online in the Azure DevOps agent pool.

---

## Your Tasks

1. **Diagnose the Issue**
   - Attempt to SSH to the agent using the public IP (provided in the outputs or portal).
   - Check the VM's networking configuration in the Azure Portal.
   - Use Azure CLI or Portal to verify if the public IP is attached and enabled.

2. **Resolve the Issue**
   - Re-enable or re-attach the public IP to the Linux agent VM using the Azure Portal or CLI.
   - Confirm that the agent is reachable via SSH and appears online in the DevOps agent pool.

3. **Document Your Steps**
   - List the troubleshooting steps you performed.
   - Include screenshots or CLI output showing the resolution.

---

## Detailed Troubleshooting Steps

### 1. Attempt SSH Connection

```bash
ssh -i ~/.ssh/terraform_lab_key azureuser@$(terraform output -raw agent_vm_public_ip)
```

If you receive a timeout or connection refused, proceed to the next step.

### 2. Check VM Networking in Azure Portal

- Go to the Azure Portal > Virtual Machines > [Your Linux Agent VM].
- Under **Networking**, verify if a public IP address is listed and attached to the network interface.
- If no public IP is present, this is likely the cause of the connectivity issue.

### 3. Use Azure CLI to Check Public IP

```bash
az vm show -g <resource-group> -n <linux-agent-vm-name> --query "networkProfile.networkInterfaces" -o json
```
Or list public IPs in the resource group:
```bash
az network public-ip list -g <resource-group> -o table
```

### 4. Re-enable or Attach Public IP

**Azure Portal:**
- Go to the VM's **Networking** blade.
- Click on the network interface.
- Under **IP configurations**, add or enable a public IP address.
- Save changes.

**Azure CLI:**
Attach a public IP to the VM's NIC:
```bash
az network nic ip-config update --resource-group <resource-group> --nic-name <nic-name> --name <ip-config-name> --public-ip-address <public-ip-name>
```

### 5. Verify SSH and Agent Pool Status

- Try SSH again:
  ```bash
  ssh -i ~/.ssh/terraform_lab_key azureuser@<linux-agent-public-ip>
  ```
- Check the agent status in Azure DevOps agent pool.

### 6. Document Your Resolution

- List the steps you performed.
- Include screenshots or CLI output showing the VM's networking before and after the fix.
- Note the agent's status in Azure DevOps after resolution.

---

## Notes

- **Do not use Terraform to fix the issue.** The lab is designed to simulate a real-world scenario where you must use Azure operational tools.
- If you need to roll back, contact your instructor or use the provided rollback instructions (if any).

---

## Example Error Message

```
##[error]The agent is not responding. Check network connectivity and firewall settings.
```

---

## Resources
- [Troubleshoot VM connectivity in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/troubleshooting/connectivity)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure DevOps Agent Pools](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues)
