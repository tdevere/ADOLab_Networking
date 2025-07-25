
# Lab: Linux Connectivity Issue 01

## Scenario

You are a DevOps support engineer. A build pipeline is failing because the Linux build agent is unreachable. The environment was provisioned for you—your job is to troubleshoot and resolve the connectivity issue using Azure tools (Portal or CLI). **Do not use Terraform to fix the problem.**

---

## Lab Setup

Follow these steps to set up your lab environment:

1. **Clone the repository and navigate to the lab folder:**
   ```bash
   git clone https://github.com/tdevere/ADOLab_Networking.git
   cd ADOLab_Networking/lab/Labs/Linux_Connectivity_Issue_01
   ```
2. **Initialize Terraform:**
   ```bash
   terraform init
   ```
3. **Create a workspace for this lab:**
   ```bash
   terraform workspace new linux_connectivity_issue_01
   ```
4. **Apply the lab configuration:**
   ```bash
   terraform plan -var-file="../../terraform/terraform.tfvars.example"
   terraform apply -var-file="../../terraform/terraform.tfvars.example" -auto-approve
   ```
5. **Obtain the Linux agent VM details:**
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
ssh -i ~/.ssh/terraform_lab_key azureuser@<linux-agent-public-ip>
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
