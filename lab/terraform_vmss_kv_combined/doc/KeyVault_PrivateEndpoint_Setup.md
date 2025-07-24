# Key Vault Private Endpoint & NSG Setup Guide

This guide walks you through the steps required to securely configure an Azure Key Vault with a private endpoint and appropriate NSG rules using Terraform.

---

## Prerequisites
- Azure subscription with sufficient permissions
- [Terraform](https://www.terraform.io/downloads.html) >= 1.4.0
- Azure CLI installed and authenticated (`az login`)

---

## Steps Overview
1. Create a resource group for Key Vault
2. Create a virtual network and subnet for the private endpoint
3. Deploy the Key Vault
4. Configure a private endpoint for the Key Vault
5. Create a Network Security Group (NSG) for the private endpoint subnet
6. Associate the NSG with the subnet
7. Add NSG rules to allow access from trusted sources

---


## Step-by-Step Instructions

### Option 1: Terraform (Recommended)
...existing code...

### Option 2: Manual Setup Using Azure Portal

#### 1. Create Resource Group
1. Go to the Azure Portal: https://portal.azure.com
2. Click **Create a resource** > **Resource group**.
3. Enter a name (e.g., `kv-rg`), select a region, and click **Review + create**.

#### 2. Create Virtual Network & Subnet
1. In the resource group, click **Create** > **Virtual network**.
2. Enter a name (e.g., `kv-vnet`), address space (e.g., `10.10.0.0/16`), and region.
3. Under **Subnets**, add a subnet for the private endpoint (e.g., `kv-pe-subnet`, `10.10.2.0/24`).
4. In subnet settings, set **Private endpoint network policies** to **Disabled**.

#### 3. Deploy Key Vault
1. In the resource group, click **Create** > **Key Vault**.
2. Enter a name, region, and select the resource group.
3. Under **Networking**, set **Network access** to **Private endpoint** only (deny public access).
4. Add the subnet created above to the Key Vault's network ACLs.
5. Complete the creation.

#### 4. Configure Private Endpoint
1. In the Key Vault resource, go to **Networking** > **Private endpoint connections**.
2. Click **+ Private endpoint**.
3. Enter a name, select the resource group, and choose the subnet created above.
4. Select **Key Vault** as the resource type and link to your Key Vault.
5. Complete the wizard to create the private endpoint.

#### 5. Create NSG for Private Endpoint Subnet
1. In the resource group, click **Create** > **Network security group**.
2. Enter a name (e.g., `kv-pe-nsg`), region, and resource group.
3. After creation, go to the NSG and add an **Inbound security rule**:
   - Source: Trusted subnet or IP (e.g., VMSS subnet)
   - Destination port: 443
   - Protocol: TCP
   - Action: Allow

#### 6. Associate NSG with Subnet
1. Go to the **kv-pe-subnet** in the VNet.
2. Under **Network security group**, select the NSG you created above.

#### 7. Validate Setup
1. In the Key Vault resource, check **Private endpoint connections** for a status of **Approved**.
2. In the subnet, confirm the NSG is associated and rules are correct.
3. Test access from a VM in the trusted subnet (e.g., VMSS) using Azure CLI:
   ```powershell
   az login --identity
   az keyvault secret list --vault-name <kv_name>
   ```

---

## Notes
- The NSG should only allow traffic from required sources (e.g., VMSS subnet, on-prem IPs).
- The subnet used for the private endpoint must have `private_endpoint_network_policies_enabled = false`.
- Key Vault network ACLs should reference the private endpoint subnet.

---

## References
- [Azure Key Vault Private Endpoint](https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service)
- [Terraform Azure Provider: Private Endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
- [Terraform Azure Provider: Network Security Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
