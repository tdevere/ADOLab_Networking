# ADOLAB_NETWORKING

A collection of Terraform‑driven **Azure DevOps** networking labs and hands‑on exercises.

```mermaid
flowchart LR
  %% Define subgraphs as stages
  subgraph STAGE1 [Lab Setup]
    direction TB
    A1[Terraform Init]
    A2[Provision Base Infra<br/>VMs, VNets, DevOps]
  end

  subgraph STAGE2 [Exercise Execution]
    direction TB
    B1[User Connects to Environment]
    B2[Runs Lab Exercises]
  end

  subgraph STAGE3 [Lab Update]
    direction TB
    C1[Terraform Plan]
    C2[Apply Updated Lab Version]
    C3[New Resources<br/>New Challenges]
  end

  subgraph STAGE4 [Lab Cleanup]
    direction TB
    D1[User Completes Labs]
    D2[Terraform Destroy]
    D3[Environment Cleaned Up]
  end

  %% Connect stages left to right
  A1 --> A2 --> B1
  B1 --> B2 --> C1
  C1 --> C2 --> C3 --> D1
  D1 --> D2 --> D3
````

## Repo Structure

* **exercises/** – Step‑by‑step Markdown exercises to walk through each lab scenario
* **lab/terraform/** – Terraform code for Agent Lab (VM + NSG) and Connectivity Lab (Key Vault, Private Endpoint, Private DNS)
* **README.md** – (You are here)

## Getting Started

1. **Clone** this repository

   ```bash
   git clone https://yourorg@dev.azure.com/yourorg/ADOLAB_NETWORKING.git
   cd ADOLAB_NETWORKING
   ```

2. **Deploy the Labs**

   > **Edit `terraform.tfvars`** with your specific settings (SSH key, subscription, etc.)

   ```bash
   cd lab/terraform
   cp terraform.tfvars.example terraform.tfvars  # see note above
   terraform init
   terraform plan
   terraform apply
   ```

3. **Run Exercises**
   Open any of the numbered folders under `exercises/` and follow the `README.md` there.
   Or get started with the [EXE\_01\_LAB\_SETUP](exercises/EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md)


## Lab Index & Exercises

### 1. Initial Setup Lab
- **File:** `exercises/EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md`
- **Exercises:**
  1. Deploy environments with Terraform
  2. Validate agent VM access (SSH for Linux, RDP for Windows)
  3. Submission & Verification
  4. Cleanup

### 2. Azure DevOps Agent Registration Lab
- **File:** `exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md`
- **Exercises:**
  1. Create an Agent Pool in Azure DevOps
  2. Register the Linux Agent
  3. Register the Windows Agent
  4. Create an ARM Service Connection to Key Vault
  5. Submission & Verification
  6. Cleanup

---

## Quick Reference: All Lab Exercises

| Lab Name                              | Exercise Description                                 | Exercise Name & Link |
|---------------------------------------|-----------------------------------------------------|----------------------|
| Initial Setup Lab                     | Deploy environments with Terraform                  | [Exercise 1: Deploy environments with Terraform](exercises/EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md#exercise-1-deploy-environments-with-terraform) |
|                                       | Validate agent VM access (SSH/RDP)                  | [Exercise 2: Validate agent VM access](exercises/EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md#exercise-2-validate-agent-vm-access) |
|                                       | Submission & Verification                           | [Submission & Verification](exercises/EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md#submission--verification) |
|                                       | Cleanup                                             | [Cleanup](exercises/EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md#cleanup) |
| Azure DevOps Agent Registration Lab    | Create an Agent Pool in Azure DevOps                | [Exercise 1: Create an Agent Pool](exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md#exercise-1-create-an-agent-pool) |
|                                       | Register the Linux Agent                            | [Exercise 2: Register the Linux Agent](exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md#exercise-2-register-the-linux-agent) |
|                                       | Register the Windows Agent                          | [Exercise 3: Register the Windows Agent](exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md#exercise-3-register-the-windows-agent) |
|                                       | Create an ARM Service Connection to Key Vault       | [Exercise 4: Create an ARM Service Connection to Key Vault](exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md#exercise-4-create-an-arm-service-connection-to-key-vault) |
|                                       | Submission & Verification                           | [Submission & Verification](exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md#submission--verification) |
|                                       | Cleanup                                             | [Cleanup](exercises/EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md#cleanup) |

## Contributing

* **Found a bug or have an idea?**
  Open an **Issue** in this project’s tracker.

* **Want to contribute a lab exercise?**

  1. Fork or branch this repo.
  2. Make your changes in the appropriate folder (`docs/`, `exercises/`, or `lab/terraform/`).
  3. Submit a **Pull Request** with a clear title and description.

* **Style & Formatting**

  * Markdown files should pass basic linting (e.g. [markdownlint](https://github.com/DavidAnson/markdownlint)).
  * Terraform code should be formatted with `terraform fmt`.