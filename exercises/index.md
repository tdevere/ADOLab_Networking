## Exercises Template (Exercise 00)

| Exercise No. | Name / Path                                                                 | Description                                                       |
|-------------:|-----------------------------------------------------------------------------|-------------------------------------------------------------------|
| 00           | [TEMPLATE](./EXE_00_TEMPLATE/EXE_00_TEMPLATE.md)                            | Initialize your exercise project using the provided template      |

---

## Lab Setup (Exercises 01–05)

| Exercise No. | Name / Path                                                                                     | Description                                                                                                   |
|-------------:|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| 01           | [Lab Setup](./EXE_01_LAB_SETUP/EXE_01_LAB_SETUP.md)                                             | Clone the lab repository, configure `terraform.tfvars`, and deploy both Agent and Connectivity labs            |
| 02           | [Configure Agent Pool](./EXE_02_CONFIGURE_ADO/EXE_02_CONFIGURE_ADO.md)                  | Createa ADO Agent Pool and Add Agents |
| 03           | [Configure Service Connection](./EXE_10_SERVICE_CONNECTION/EXE_10_SERVICE_CONNECTION.md)         | Create an Azure DevOps service connection granting pipeline access to the lab’s Key Vault                    |
| 04           | [Configure Pipeline](./EXE_11_PIPELINE_CONFIG/EXE_11_PIPELINE_CONFIG.md)                         | Create or update a pipeline in Azure DevOps using the provided YAML and link it to the Key Vault connection |

---

## Simulations (Exercises 06–08)

| Exercise No. | Name / Path                                                                                         | Description                                                                                                  |
|-------------:|-----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| 05           | [Private Endpoint Access Denied](./EXE_06_PRIVATE_ENDPOINT_BLOCK/EXE_06_PRIVATE_ENDPOINT_BLOCK.md)   | Attempt to fetch a secret from Key Vault when the private endpoint configuration blocks access               |
| 06           | [DNS Misresolution Simulation](./EXE_07_DNS_MISRESOLUTION/EXE_07_DNS_MISRESOLUTION.md)               | Use the misconfigured DNS A-record and observe pipeline failure due to wrong DNS resolution                   |
| 07           | [NSG Firewall Simulation](./EXE_08_NSG_TEST/EXE_08_NSG_TEST.md)                                      | Temporarily block outbound traffic to Key Vault via NSG, then restore rules and verify connectivity           |

---

## Troubleshooting Exercises (Exercises 09–10)

| Exercise No. | Name / Path                                                                                 | Description                                                                              |
|-------------:|---------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| 08           | [Retrieve a Key Vault Secret](./EXE_09_KEYVAULT_SECRET/EXE_09_KEYVAULT_SECRET.md)            | From the Linux agent, use the Azure CLI to fetch a secret from the lab’s Key Vault       |
| 09           | [Validate Private Endpoint DNS](./EXE_10_DNS_CORRECT/EXE_10_DNS_CORRECT.md)                  | Resolve the Key Vault FQDN in the Private DNS zone and connect successfully             |

---

## Data Collection: Inventory Script (Exercise 11)

| Exercise No. | Name / Path                                                                                   | Description                                                                                         |
|-------------:|-----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| 10           | [Inventory Script](./EXE_11_INVENTORY_SCRIPT/EXE_11_INVENTORY_SCRIPT.md)                      | Execute the PowerShell inventory script, then analyze the generated CSV/JSON to validate your setup |
---


## Optional Labs

| Lab No. | Name / Path                                                               | Description                                                                                                                  |
| ------: | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
|   OL-01 | [Tracing Packet Capture](./OPTIONAL_01_TRACING/OPTIONAL_01_TRACING.md)    | Enable `tcpdump` or Packet Capture on your agents, collect NSG flow logs, and explore Azure Network Watcher trace routes.    |
|   OL-02 | [Tools Overview](./OPTIONAL_02_TOOLS/OPTIONAL_02_TOOLS.md)                | Survey Azure network troubleshooting tools: Network Watcher, NSG Flow Logs, Connection Troubleshoot, Traffic Analytics.      |
|   OL-03 | [AI-Assisted Diagnostics](./OPTIONAL_03_AI/OPTIONAL_03_AI.md)             | Leverage GitHub Copilot or Azure AI Insights to analyze network logs and suggest remediation steps.                          |
|   OL-04 | [Monitoring & Alerts](./OPTIONAL_04_MONITORING/OPTIONAL_04_MONITORING.md) | Configure Azure Monitor, Log Analytics, and Alert rules to detect and notify on networking anomalies.                        |
|   OL-05 | [Automation Scripts](./OPTIONAL_05_AUTOMATION/OPTIONAL_05_AUTOMATION.md)  | Automate network troubleshooting via Azure CLI/PowerShell scripts and ARM templates for rapid diagnostics.                   |
|   OL-06 | [Security Auditing](./OPTIONAL_06_AUDITING/OPTIONAL_06_AUDITING.md)       | Use Azure Policy and Azure Security Center to audit and enforce network security configurations across your lab environment. |
