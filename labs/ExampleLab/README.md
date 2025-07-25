# Lab: Linux Connectivity Issue 01

## Scenario

You are a DevOps support engineer. The Linux build agent is unreachable due to a missing public IP. Your job is to troubleshoot and resolve the connectivity issue using Azure tools (Portal or CLI). **Do not use Terraform to fix the problem.**

---

## How to Run This Scenario

1. **Navigate to the base lab folder:**
   ```powershell
   cd ../ExampleLab
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
   cd ADOLab_Networking/labs/ExampleLab
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

## Your Tasks (Examples)

1. **Deploy the Example Lab**
   - Use Terraform to provision the lab resources as described above.
   - Supply scenario variables as needed.

2. **Validate Resource Creation**
   - Confirm that the agent VM, networking, and Key Vault resources are created successfully.
   - Use Terraform outputs and the Azure Portal to inspect resource properties.

3. **Document Your Results**
   - List the steps you performed to deploy and validate the lab.
   - Optionally include screenshots or CLI output showing the resources.

---

## Detailed Troubleshooting Steps


## Example Validation Steps

1. **Check Terraform Outputs**
   - After `terraform apply`, review the outputs for VM public IP, Key Vault private endpoint, and DNS records.

2. **Inspect Resources in Azure Portal**
   - Confirm the agent VM, networking, and Key Vault resources exist and match your scenario variables.

3. **Test SSH Connectivity (Optional)**
   - If a public IP is provisioned, try:
     ```bash
     ssh -i ~/.ssh/terraform_lab_key azureuser@$(terraform output -raw agent_vm_public_ip)
     ```

4. **Document Your Results**
   - List the steps you performed and any outputs or screenshots that validate the lab deployment.

---

## Resources
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
