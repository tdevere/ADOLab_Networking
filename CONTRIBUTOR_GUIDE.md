# Contributor Guide: Azure Networking Lab Resource Management

## Problem Description

When switching between lab configurations using Terraform, resources are being unnecessarily destroyed and recreated instead of being preserved and updated in-place. This causes:

- **Longer deployment times** (4 to add, 4 to destroy instead of simple updates)
- **IP address changes** for VMs (breaking saved connections)
- **Potential lab disruption** if students are mid-exercise
- **Resource waste** and cost implications

## Root Cause Analysis

The issue occurs when Terraform configurations use **different resource names** between lab scenarios, forcing resource recreation instead of in-place updates.

### Example of the Problem:
```hcl
# Linux_Connectivity_Issue_01/scenario.tfvars
agent_rg_name = "rg-agent-connectivity-lab"
vm_name = "vm-linux-agent" 
key_vault_name = "kv-connectivity-lab"

# base.tfvars (PROBLEMATIC)
agent_rg_name = "rg-agent-lab"          # Different name!
vm_name = "vm-linux-base"               # Different name!
key_vault_name = "kv-connectivity-lab-01"  # Different name!
```

When resource names change, Azure requires **destroying** the old resource and **creating** a new one, because you cannot rename Azure resources in-place.

## Solution Strategy

### ✅ **Option 1: Standardize Resource Names (Recommended)**

Use consistent naming across all lab configurations to enable in-place updates:

```hcl
# Both scenario.tfvars AND base.tfvars should use:
agent_rg_name = "rg-agent-connectivity-lab"     # Consistent
vm_name = "vm-linux-agent"                      # Consistent  
key_vault_name = "kv-connectivity-lab-01"       # Consistent
```

### ❌ **Option 2: Accept Recreation (Not Recommended)**

Allowing resource destruction can disrupt ongoing labs and wastes resources.

## Lab Restoration Concepts

### **The Restoration Problem**

In educational lab environments, you need reliable ways to reset labs between students or restore them to different states without:
- 🚫 Destroying expensive infrastructure
- 🚫 Breaking ongoing student work
- 🚫 Causing long redeployment times
- 🚫 Changing IP addresses that students may have saved

### **Restoration Strategies Comparison**

| Strategy | Speed | Safety | Complexity | Use Case |
|----------|-------|--------|------------|----------|
| **CLI Commands** | ⚡ Fastest (15s) | ✅ Safe | 🟢 Simple | Quick instructor resets |
| **Terraform Updates** | 🔄 Medium (30s) | ✅ Safe | 🟡 Moderate | Clean state management |
| **Terraform Recreation** | 🐌 Slow (5+ min) | ❌ Destructive | 🔴 Complex | Complete rebuilds only |

### **Multi-Level Restoration Approach**

#### **Level 1: Quick CLI Fixes (Student Solutions)**
Students learn to fix issues using Azure operational tools:
```bash
# Student fixes connectivity issue
az network nic ip-config update \
  --resource-group rg-agent-connectivity-lab \
  --nic-name nic-linux-agent \
  --name ipconfig1 \
  --public-ip-address pip-linux-agent
```

#### **Level 2: Quick CLI Reset (Instructor Management)**
Instructors can quickly restore broken state for next student:
```bash
# Instructor restores broken state
az network nic ip-config update \
  --resource-group rg-agent-connectivity-lab \
  --nic-name nic-linux-agent \
  --name ipconfig1 \
  --remove publicIpAddress
```

#### **Level 3: Terraform State Management (Clean Transitions)**
Use Terraform for clean, reliable state transitions:
```powershell
# Switch to working baseline (preserves all resources)
terraform apply -var-file="base.tfvars" -var="admin_ssh_key=$sshkey"

# Switch to specific lab scenario (preserves all resources) 
terraform apply -var-file="../SomeScenario/scenario.tfvars" -var="admin_ssh_key=$sshkey"
```

#### **Level 4: Complete Teardown (Rare)**
Only for complete lab cleanup:
```powershell
# Nuclear option - destroys everything
terraform destroy -auto-approve
```

### **Base Configuration Concept**

A **base configuration** provides a known-good state that serves as:
- ✅ **Working baseline** where all components function normally
- ✅ **Reference point** for validating infrastructure health
- ✅ **Starting point** for new lab scenarios
- ✅ **Fallback state** when labs have issues

**Key Characteristics of Base Config:**
```hcl
# base.tfvars - Normal working state
lab_scenario = "base"                    # Triggers normal operation
# All resource names identical to other scenarios
# All networking components functional
# No intentional issues for troubleshooting
```

### **Conditional Logic Implementation**

The restoration system works through conditional logic in `main.tf`:

```hcl
# Example: Linux VM public IP attachment logic
resource "azurerm_network_interface" "vm_nic" {
  ip_configuration {
    # Conditionally attach public IP based on scenario
    public_ip_address_id = var.lab_scenario == "Linux_Connectivity_Issue_01" ? null : azurerm_public_ip.vm_public_ip.id
  }
}
```

**Results:**
- `lab_scenario = "base"` → Linux VM **has** public IP (working)
- `lab_scenario = "Linux_Connectivity_Issue_01"` → Linux VM **missing** public IP (broken)

### **Resource Preservation Principle**

**Core Principle:** *Preserve resources, change behavior*

Instead of creating different resources with different names:
```hcl
# ❌ BAD: Different resource names cause destruction
# scenario1.tfvars
vm_name = "vm-linux-scenario1"

# scenario2.tfvars  
vm_name = "vm-linux-scenario2"  # Forces VM destruction and recreation!
```

Use identical resources with different behaviors:
```hcl
# ✅ GOOD: Same resource names, different behaviors
# Both files use:
vm_name = "vm-linux-agent"      # Consistent naming

# Behavior controlled by lab_scenario variable:
lab_scenario = "scenario1"      # vs "scenario2"
```

## Implementation Guidelines

### **1. Resource Naming Standards**

All `.tfvars` files should use these standardized names:

```hcl
# Agent Lab Resources (STANDARD NAMES)
agent_rg_name               = "rg-agent-connectivity-lab"
agent_vnet_name             = "vnet-agent-connectivity" 
agent_subnet_name           = "subnet-agent"
vm_name                     = "vm-linux-agent"
public_ip_name              = "pip-linux-agent"
nic_name                    = "nic-linux-agent"

# Connectivity Lab Resources (STANDARD NAMES)
connect_rg_name             = "rg-connectivity-lab"
connect_vnet_name           = "vnet-connectivity-lab"
key_vault_name              = "kv-connectivity-lab"
```

### **2. Configuration Differences Should Be Behavioral**

Lab scenarios should differ in **behavior** (controlled by variables), not **naming**:

```hcl
# Use lab_scenario to control behavior, not names
lab_scenario = "Linux_Connectivity_Issue_01"  # vs "base"

# This drives conditional logic in main.tf:
public_ip_address_id = var.lab_scenario == "Linux_Connectivity_Issue_01" ? null : azurerm_public_ip.vm_public_ip.id
```

### **3. Testing Resource Updates**

Before committing configuration changes, verify they result in updates rather than recreation:

```powershell
# Good: Should show "~ update in-place"
terraform plan -var-file="new-config.tfvars"

# Look for:
# ~ resource "azurerm_network_interface" "vm_nic" {
#   # (changes without destroying)

# Bad: Shows "-/+ destroy and then create replacement" 
# This indicates resource naming conflicts
```

## File Structure Standards

```
labs/
├── base_lab/
│   ├── base.tfvars              # Standard names, lab_scenario = "base"
│   ├── main.tf                  # Conditional logic based on lab_scenario
│   └── variables.tf             # Variable definitions
├── Linux_Connectivity_Issue_01/
│   ├── scenario.tfvars          # Same names as base, lab_scenario = "Linux_Connectivity_Issue_01"
│   └── README.md                # Lab instructions
└── [Future_Lab_Scenario]/
    ├── scenario.tfvars          # Same names as base, lab_scenario = "Future_Lab_Scenario"
    └── README.md
```

## Configuration Review Checklist

Before adding new lab configurations:

- [ ] **Resource names match existing standards**
- [ ] **Only `lab_scenario` variable differs between configs**
- [ ] **`terraform plan` shows updates, not recreation**
- [ ] **All resource groups use standard names**
- [ ] **VM names are consistent across scenarios**
- [ ] **Network resources use standard naming**
- [ ] **Key Vault and other shared resources unchanged**

## Troubleshooting Recreation Issues

If you see unwanted resource recreation:

### **1. Compare Configuration Files**
```powershell
# Find naming differences
Compare-Object (Get-Content base.tfvars) (Get-Content ../SomeScenario/scenario.tfvars)
```

### **2. Check Terraform Plan Output**
```powershell
terraform plan -var-file="scenario.tfvars" | findstr -C:3 "destroy and then create"
```

### **3. Identify Root Cause**
Look for lines showing `# forces replacement` in the plan output:
```hcl
~ name = "old-name" -> "new-name" # forces replacement
```

### **4. Fix the Configuration**
Update the `.tfvars` file to use consistent naming:
```hcl
# Change this:
vm_name = "vm-different-name"

# To this:
vm_name = "vm-linux-agent"  # Matches existing standard
```

## Best Practices for Contributors

### **When Adding New Lab Scenarios:**

1. **Copy existing scenario.tfvars** as template
2. **Only change `lab_scenario` variable**
3. **Test with `terraform plan`** to verify no destruction
4. **Document the lab purpose and behavior**
5. **Update main.tf conditional logic if needed**

### **When Modifying Existing Labs:**

1. **Never change resource names** in existing configs
2. **Use `lab_scenario` for behavioral differences**
3. **Test against existing deployments**
4. **Validate no student disruption**

### **When Creating Base Configurations:**

1. **Use names from most common existing lab**
2. **Set `lab_scenario = "base"` for normal operation**
3. **Ensure all resources work properly**
4. **Document expected behavior**

## Testing and Validation

### **Before Submitting Changes:**

```powershell
# 1. Validate syntax
terraform validate

# 2. Test update path (should show minimal changes)
terraform plan -var-file="new-config.tfvars"

# 3. Verify no resource destruction
terraform plan -var-file="new-config.tfvars" | findstr "destroy"
# Should return no results for planned changes

# 4. Test switching between configurations
terraform apply -var-file="base.tfvars" -auto-approve
terraform plan -var-file="../SomeScenario/scenario.tfvars"
```

### **Acceptance Criteria:**

- ✅ Configuration switching shows only `~ update in-place`
- ✅ No resource destruction unless explicitly intended
- ✅ VM IP addresses remain stable across switches
- ✅ Students can continue labs without disruption
- ✅ Documentation clearly explains the behavioral differences

## Example: Fixing the Current Issue

### **Problem Configuration (base.tfvars):**
```hcl
# This causes recreation:
agent_rg_name = "rg-agent-lab"           # Different!
key_vault_name = "kv-connectivity-lab-01" # Different!
```

### **Fixed Configuration (base.tfvars):**
```hcl
# This enables updates:
agent_rg_name = "rg-agent-connectivity-lab"  # Matches existing
key_vault_name = "kv-connectivity-lab-01"    # Matches existing (current deployed state)
lab_scenario = "base"                        # Only this should differ
```

### **Verification Results:**

**Before Fix (Resource Recreation):**
```
Plan: 4 to add, 2 to change, 4 to destroy.
# Resources being destroyed and recreated unnecessarily
```

**After Fix (In-Place Updates):**
```
Plan: 0 to add, 1 to change, 0 to destroy.
# Only the network interface configuration changes
~ azurerm_network_interface.vm_nic {
    ~ ip_configuration {
        + public_ip_address_id = "..."  # Adds public IP for working state
    }
}
```

**Switching Back to Broken State:**
```
Plan: 0 to add, 2 to change, 0 to destroy.
~ azurerm_network_interface.vm_nic {
    ~ ip_configuration {
        - public_ip_address_id = "..." -> null  # Removes public IP for connectivity issue
    }
}
```

### **Lab Management Workflow:**

1. **Deploy Initial Lab:**
   ```powershell
   terraform apply -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars"
   # Creates broken connectivity scenario
   ```

2. **Student Fixes Issue:**
   ```bash
   az network nic ip-config update --add publicIpAddress pip-linux-agent
   # Student learns Azure CLI troubleshooting
   ```

3. **Instructor Reset (Option A - CLI):**
   ```bash
   az network nic ip-config update --remove publicIpAddress
   # Quick 15-second reset for next student
   ```

4. **Instructor Reset (Option B - Terraform):**
   ```powershell
   terraform apply -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars"
   # Clean 30-second reset with guaranteed state
   ```

5. **Switch to Base Configuration:**
   ```powershell
   terraform apply -var-file="base.tfvars"
   # Restore to fully working baseline
   ```

### **Resource Preservation Success Metrics:**

✅ **Fast Transitions:** 15-30 seconds instead of 5+ minutes  
✅ **Stable IP Addresses:** VMs keep same IPs across resets  
✅ **No Destruction:** All infrastructure preserved  
✅ **Cost Efficient:** No unnecessary resource recreation  
✅ **Student Safe:** No interruption of ongoing work

## Future Enhancements

Consider implementing:

- **Automated validation** in CI/CD to catch naming inconsistencies
- **Resource tagging standards** for lab management
- **State locking** to prevent concurrent modifications
- **Configuration templates** for new lab scenarios
- **Lab state verification scripts** to confirm expected configurations
- **Automated restoration testing** in CI/CD pipelines
- **Student progress tracking** integration with restoration points
- **Resource cost monitoring** for lab efficiency optimization

## Common Restoration Scenarios

### **Scenario 1: Student Completed Lab**
```powershell
# Quick reset for next student
az network nic ip-config update --remove publicIpAddress
# OR for guaranteed clean state:
terraform apply -var-file="../Linux_Connectivity_Issue_01/scenario.tfvars"
```

### **Scenario 2: Infrastructure Validation**
```powershell
# Restore to base to verify all components work
terraform apply -var-file="base.tfvars"
terraform output  # Verify all outputs are healthy
```

### **Scenario 3: Switching Lab Types**
```powershell
# From connectivity lab to future DNS lab
terraform apply -var-file="../DNS_Troubleshooting_Lab/scenario.tfvars"
# Resources preserved, only behavior changes
```

### **Scenario 4: Emergency Recovery**
```powershell
# If lab is in unknown state
terraform apply -var-file="base.tfvars" -auto-approve
# Guaranteed return to working baseline
```

### **Scenario 5: Multi-Student Environment**
```bash
# Create separate resource groups per student
for student in student1 student2 student3; do
  terraform apply -var-file="scenario.tfvars" \
    -var="agent_rg_name=rg-${student}-connectivity-lab" \
    -var="workspace=${student}"
done
```

## Lab State Documentation Standards

When creating new lab scenarios, document the expected states:

### **Expected State Documentation Template:**
```markdown
## Lab: [Scenario Name]

### **Initial State (Broken):**
- ❌ Linux VM: No public IP attached
- ✅ Windows VM: Has public IP (working baseline)
- 🔧 Public IP: Exists but unattached
- 📊 Expected student resolution time: 15-30 minutes

### **Student Goal State (Fixed):**
- ✅ Linux VM: Public IP attached and functional
- ✅ SSH connectivity confirmed
- 🎓 Learning outcome: Azure CLI networking commands

### **Restoration Commands:**
```bash
# Quick reset (15 seconds)
az network nic ip-config update --remove publicIpAddress

# Clean reset (30 seconds)  
terraform apply -var-file="scenario.tfvars"
```

### **Validation Commands:**
```bash
# Verify broken state
az network nic show --query "ipConfigurations[0].publicIpAddress" # Should be null

# Verify fixed state  
Test-NetConnection -ComputerName $publicIP -Port 22  # Should succeed
```
```

## Questions and Support

For questions about this resource management approach:

1. **Check existing configurations** for naming patterns
2. **Test changes** with `terraform plan` first
3. **Document behavioral differences** clearly
4. **Consider student impact** of any changes
5. **Validate restoration paths** before deploying to students
6. **Monitor resource costs** and optimization opportunities

### **Emergency Contacts and Procedures:**

If a lab environment becomes unrecoverable:
1. **Immediate action:** `terraform apply -var-file="base.tfvars"` to restore baseline
2. **Document the issue** for root cause analysis
3. **Test restoration** before allowing student access
4. **Update procedures** based on lessons learned

### **Contributing Restoration Improvements:**

When proposing changes that affect restoration:
1. **Test all restoration paths** (CLI + Terraform)
2. **Verify no resource destruction** in plan output
3. **Document new restoration procedures**
4. **Update this guide** with new scenarios or improvements
5. **Consider backward compatibility** with existing labs

Remember: **Preserve resources, change behavior** - this is the key principle for successful lab configuration management.

## Appendix: Terraform State Management Best Practices

### **State File Safety:**
- Always use remote state (Azure Storage) for team environments
- Enable state locking to prevent corruption
- Backup state files before major changes
- Never manually edit state files

### **Plan Review Checklist:**
```powershell
# Always review plans before applying
terraform plan -var-file="config.tfvars" | findstr -E "(add|change|destroy)"

# Look for unexpected changes:
# - Any "destroy" operations (unless intended)
# - Large numbers of resources changing
# - Resource name changes ("forces replacement")
```

### **Rollback Procedures:**
```powershell
# If applied change causes issues:
terraform apply -var-file="base.tfvars"  # Return to baseline

# If state corruption occurs:
terraform import [resource_type].[resource_name] [azure_resource_id]
```

This comprehensive restoration framework ensures reliable, efficient lab management while minimizing risk to student learning environments.
