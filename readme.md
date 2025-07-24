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