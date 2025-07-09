# ADOLAB_NETWORKING

A collection of Terraform-driven **Azure DevOps** networking labs and hands-on exercises.

## Repo Structure

- **exercises/** – Step-by-step markdown exercises to walk through each lab scenario  
- **lab/terraform/** – Terraform code for Agent Lab (VM + NSG) and Connectivity Lab (Key Vault, Private Endpoint, Private DNS)  
- **docs/** – Supplemental documentation (now tracked!)  
- **scripts/** – Helper scripts (e.g. inventory exporter)  
- **README.md** – (You are here)  

## Getting Started

1. **Clone** this repository  
   ```bash
   git clone https://yourorg@dev.azure.com/yourorg/ADOLAB_NETWORKING.git
   cd ADOLAB_NETWORKING
   ```


2. **Deploy the Labs**

   ```bash
   cd lab/terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings (SSH key, subscription, etc.)
   terraform init
   terraform plan
   terraform apply
   ```

3. **Run Exercises**
   Open any of the numbered folders under `exercises/` and follow the `README.md` there.

## Contributing

* **Found a bug or have an idea?**
  Open an **Issue** in this project’s tracker.

* **Want to contribute?**

  1. Fork or branch this repo.
  2. Make your changes in the appropriate folder (`docs/`, `exercises/`, or `lab/terraform/`).
  3. Submit a **Pull Request** with a clear title and description.

* **Style & Formatting**

  * Markdown files should pass basic linting (e.g. [markdownlint](https://github.com/DavidAnson/markdownlint)).
  * Terraform code should be formatted with `terraform fmt`.

---
