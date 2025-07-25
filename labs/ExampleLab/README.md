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


## Example Symptoms (Sample Data)

- Azure DevOps pipeline fails with error:
  > Example error: Agent unreachable: SSH connection timed out
- You cannot SSH to the Linux agent using its public IP (e.g., 52.160.10.123).
- The agent does not appear online in the Azure DevOps agent pool (pool: ExamplePool).

*Note: These are example symptoms for demonstration purposes only.*

## Example Tasks (Sample Data)

1. Attempt to SSH to the agent using the public IP (e.g., `52.160.10.123`).
2. Check the VM's networking configuration in the Azure Portal (VM name: `example-agent-vm`).
3. Use Azure CLI or Portal to verify if the public IP is attached and enabled (resource group: `example-rg`).
4. Re-enable or re-attach the public IP using Azure Portal or CLI if needed.
5. Confirm the agent is reachable via SSH and appears online in the DevOps agent pool (pool: `ExamplePool`).
6. Document your troubleshooting steps and resolution (screenshots, CLI output, etc.).

*Note: These are example tasks for demonstration purposes only. Replace with your actual lab steps as needed.*

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

## Restoring to the Base Lab Version

After completing this example lab, you can restore your environment to the original base_lab version:

1. Change to the base lab directory:
   ```powershell
   cd ../base_lab
   ```
2. Re-apply the base lab configuration:
   ```powershell
   $sshkey = Get-Content $env:USERPROFILE\.ssh\terraform_lab_key.pub
   terraform plan -var-file="terraform.tfvars" -var="admin_ssh_key=$sshkey" -out=tfplan
   terraform apply tfplan
   ```
3. This will reset your environment to the base lab state.

---

## Resources
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)

## Notes
- Do not use Terraform to fix the issue. The lab simulates a real-world operational scenario.
- If you need to roll back, contact your instructor or use provided rollback instructions.
