# Azure Infrastructure as Code with Terraform

## Overview

This project documents my hands-on learning of **Infrastructure as Code (IaC)** using Terraform and Microsoft Azure.

Rather than manually creating cloud resources through the Azure Portal, the infrastructure is defined as Terraform configuration and deployed through the Azure Resource Manager APIs.

The project started with a simple Azure Resource Group and progressively introduced networking, network security, compute, SSH authentication, Terraform state, resource dependencies, and outputs.

The primary objective is not only to deploy infrastructure, but to understand how Terraform manages cloud resources and how Infrastructure as Code can be used to create repeatable and maintainable environments.

---

## Architecture

The current lab architecture is:

```text
Azure Subscription
│
└── Resource Group
    └── tf-learning-rg
        │
        └── Virtual Network
            └── lab-vnet
                10.10.0.0/16
                │
                ├── Management Subnet
                │   └── 10.10.1.0/24
                │
                └── Application Subnet
                    └── 10.10.2.0/24
                        │
                        ├── application-nsg
                        │   │
                        │   └── Allow SSH from
                        │       Management Subnet
                        │
                        └── Network Interface
                            │
                            └── Ubuntu Linux VM
                                └── app-vm
```

The application VM is deployed without a public IP address.

---

## Technologies Used

- Terraform
- Microsoft Azure
- Azure CLI
- Azure Resource Manager
- Azure Virtual Network
- Azure Network Security Groups
- Ubuntu Linux
- SSH public/private key authentication
- Git
- GitHub
- Visual Studio Code

---

# Project Structure

```text
terraform-azure-lab/
│
├── main.tf
├── network.tf
├── security.tf
├── compute.tf
├── outputs.tf
├── README.md
├── .gitignore
└── .terraform.lock.hcl
```

Terraform reads all `.tf` files in the working directory as a single configuration.

The files are separated mainly to improve organization and readability.

### `main.tf`

Contains the Terraform provider configuration and Azure Resource Group.

### `network.tf`

Contains:

- Virtual Network
- Management subnet
- Application subnet

### `security.tf`

Contains:

- Network Security Group
- NSG/subnet association
- Custom security rules

### `compute.tf`

Contains:

- Network interface
- Linux virtual machine
- SSH public key configuration
- Operating system image configuration

### `outputs.tf`

Contains useful Terraform outputs such as the VM private IP address.

---

# Infrastructure as Code

Infrastructure as Code is the practice of defining infrastructure through configuration files instead of manually creating resources through a graphical interface.

A traditional deployment might require:

```text
Azure Portal
    │
    ├── Create Resource Group
    ├── Create VNet
    ├── Create Subnets
    ├── Create NSG
    ├── Create NIC
    └── Create VM
```

With Terraform, the desired infrastructure is defined as code:

```hcl
resource "azurerm_resource_group" "lab" {
  name     = "tf-learning-rg"
  location = "Japan East"
}
```

Terraform then communicates with Azure to create and manage the required resources.

---

# Terraform Resource Syntax

A Terraform resource generally follows this structure:

```hcl
resource "<RESOURCE_TYPE>" "<LOCAL_NAME>" {
  # configuration
}
```

Example:

```hcl
resource "azurerm_resource_group" "lab" {
  name     = "tf-learning-rg"
  location = "Japan East"
}
```

There are three important concepts here.

## Resource Type

```text
azurerm_resource_group
```

This tells Terraform which type of resource is being managed.

## Terraform Local Name

```text
lab
```

This is the name Terraform uses internally to identify this particular resource.

Terraform therefore addresses the resource as:

```text
azurerm_resource_group.lab
```

## Azure Resource Name

The following property:

```hcl
name = "tf-learning-rg"
```

defines the actual name visible in Microsoft Azure.

Therefore:

```text
Terraform address                  Azure resource

azurerm_resource_group.lab   --->  tf-learning-rg
```

---

# Resource References

One of the important concepts learned during this project was referencing one Terraform resource from another.

For example:

```hcl
resource_group_name = azurerm_resource_group.lab.name
```

The reference can be understood as:

```text
RESOURCE TYPE
      .
LOCAL NAME
      .
ATTRIBUTE
```

Example:

```text
azurerm_resource_group.lab.name
```

Terraform obtains the Resource Group name from the Resource Group resource rather than requiring the value to be hardcoded again.

Another example is:

```hcl
subnet_id = azurerm_subnet.application.id
```

This allows a network interface or another resource to reference the Azure ID of the application subnet.

---

# Resource Dependencies

Terraform uses resource references to determine dependencies between resources.

For example:

```text
Resource Group
      │
      ▼
Virtual Network
      │
      ▼
Application Subnet
      │
      ▼
Network Interface
      │
      ▼
Linux VM
```

Because the network interface references:

```hcl
azurerm_subnet.application.id
```

Terraform understands that the subnet must exist before the network interface can be created.

Similarly, because the VM references:

```hcl
azurerm_network_interface.app.id
```

Terraform knows that the NIC must exist before the VM.

This allows Terraform to construct a dependency graph automatically.

---

# Azure Networking

The lab uses the following address space:

```text
VNet
10.10.0.0/16
```

Two subnets were created:

```text
10.10.0.0/16
│
├── Management Subnet
│   10.10.1.0/24
│
└── Application Subnet
    10.10.2.0/24
```

The separate subnets provide a foundation for applying different network security policies to different workloads.

---

# Network Security

An Azure Network Security Group was created for the application subnet.

```text
application-subnet
        │
        ▼
 application-nsg
```

A custom inbound rule was created to allow SSH traffic from the management subnet:

```text
Source
10.10.1.0/24
     │
     │ TCP/22
     ▼
10.10.2.0/24
Application Subnet
```

Example configuration:

```hcl
resource "azurerm_network_security_rule" "allow_ssh_from_management" {
  name                       = "Allow-SSH-From-Management"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "10.10.1.0/24"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.application.name
}
```

The VM was intentionally deployed without a public IP address.

---

# Linux Virtual Machine

An Ubuntu Linux VM named:

```text
app-vm
```

was deployed into the application subnet.

Its network relationship is:

```text
application-subnet
        │
        ▼
    app-vm-nic
        │
        ▼
      app-vm
```

SSH key authentication is used instead of storing an administrator password in the Terraform configuration.

---

# SSH Authentication

A local SSH key pair was generated:

```text
Private key
terraform-azure-lab

Public key
terraform-azure-lab.pub
```

The public key is provided to Azure:

```hcl
admin_ssh_key {
  username   = "azureuser"
  public_key = file("~/.ssh/terraform-azure-lab.pub")
}
```

The private key remains on the administrator workstation and must never be committed to GitHub.

Conceptually:

```text
Administrator PC                 Azure VM

Private Key                     Public Key
     │                              │
     └──────── SSH ─────────────────┘
```

---

# Ubuntu Platform Image

The VM uses an Ubuntu Server image from Canonical.

```hcl
source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
```

An important troubleshooting lesson occurred during deployment.

The original SKU was incorrectly configured as:

```text
22.04-lts-gen2
```

Azure returned:

```text
PlatformImageNotFound
```

The available Azure images were investigated using Azure CLI.

The correct SKU was:

```text
22_04-lts-gen2
```

The difference was:

```text
Incorrect: 22.04-lts-gen2
              ^

Correct:   22_04-lts-gen2
              ^
```

This demonstrated the importance of using exact cloud resource identifiers instead of assuming or guessing image names.

---

# Terraform Workflow

The basic workflow used throughout the project is:

```text
Write Terraform Configuration
           │
           ▼
    terraform init
           │
           ▼
     terraform fmt
           │
           ▼
   terraform validate
           │
           ▼
    terraform plan
           │
           ▼
     Review Changes
           │
           ▼
    terraform apply
           │
           ▼
 Azure Infrastructure
```

---

# Terraform Commands Learned

## Check Terraform Version

```bash
terraform --version
```

Displays the installed Terraform version.

---

## Initialize

```bash
terraform init
```

Initializes the Terraform working directory.

It also downloads required providers such as AzureRM.

---

## Format

```bash
terraform fmt
```

Automatically formats Terraform configuration files using Terraform's standard formatting conventions.

---

## Validate

```bash
terraform validate
```

Checks whether the Terraform configuration is structurally valid.

---

## Plan

```bash
terraform plan
```

Calculates and displays the infrastructure changes Terraform intends to perform.

Example:

```text
Plan: 2 to add, 0 to change, 0 to destroy.
```

Terraform plan symbols include:

```text
+ Create
~ Update
- Destroy
```

The plan should always be reviewed before infrastructure changes are applied.

---

## Apply

```bash
terraform apply
```

Applies the proposed infrastructure changes.

Terraform requests confirmation before making the changes.

---

## State List

```bash
terraform state list
```

Lists resources currently tracked by Terraform state.

Example:

```text
azurerm_resource_group.lab
azurerm_virtual_network.lab
azurerm_subnet.application
azurerm_network_security_group.application
azurerm_network_interface.app
azurerm_linux_virtual_machine.app
```

---

## State Show

```bash
terraform state show azurerm_resource_group.lab
```

Displays detailed state information about a specific Terraform-managed resource.

---

## Outputs

```bash
terraform output
```

Displays values defined using Terraform output blocks.

For example:

```hcl
output "app_vm_private_ip" {
  description = "Private IP address of the application VM"
  value       = azurerm_network_interface.app.private_ip_address
}
```

This can return a value such as:

```text
app_vm_private_ip = "10.10.2.4"
```

---

## Preview Destruction

```bash
terraform plan -destroy
```

Displays which resources Terraform intends to remove without immediately deleting them.

---

## Destroy Infrastructure

```bash
terraform destroy
```

Destroys infrastructure managed by the current Terraform state.

This is useful for temporary lab environments to prevent unnecessary cloud costs.

---

# Terraform State

Terraform maintains information about managed infrastructure in its state.

For a local lab, the state is typically stored in:

```text
terraform.tfstate
```

The relationship can be visualized as:

```text
main.tf / *.tf
"What I want"
       │
       ▼
    Terraform
       │
       ├──────── Terraform State
       │         "What I manage"
       │
       ▼
      Azure
"What actually exists"
```

State allows Terraform to determine whether resources should be:

```text
Created
Modified
Destroyed
Left unchanged
```

State files should not normally be manually edited.

For production/team environments, remote state should be used instead of relying only on a local state file.

---

# Partial Deployment Failure

Another useful lesson occurred when the VM deployment initially failed because of the incorrect Ubuntu image SKU.

The network interface had already been successfully created before VM creation failed.

Terraform therefore had a state similar to:

```text
NIC      -> Created
VM       -> Failed
```

After correcting the image configuration, Terraform did not recreate everything from the beginning.

Instead, the next plan recognized the resources that already existed and continued with the missing VM.

This demonstrated the importance of Terraform state when recovering from partially successful deployments.

---

# Desired State

Terraform uses a declarative model.

Instead of providing a sequence such as:

```text
Create Resource Group
Create VNet
Create Subnet
Create NIC
Create VM
```

the configuration describes the desired final infrastructure.

Terraform determines which actions are required to reach that state.

If the infrastructure already matches the configuration:

```bash
terraform plan
```

should report:

```text
No changes.
```

---

# Outputs

Outputs provide useful information after infrastructure deployment.

The project currently exposes the VM private IP address:

```hcl
output "app_vm_private_ip" {
  description = "Private IP address of the application VM"
  value       = azurerm_network_interface.app.private_ip_address
}
```

This avoids needing to manually search Azure Portal for commonly required information.

---

# Security Considerations

The project follows several basic security principles:

- SSH key authentication instead of hardcoded passwords
- No public IP address assigned to the application VM
- Network Security Group associated with the application subnet
- SSH rule scoped to the management subnet
- Terraform state excluded from Git
- Private SSH keys excluded from Git
- Secrets should not be stored directly in Terraform configuration
- Infrastructure changes should be reviewed using `terraform plan`

The `.gitignore` should include at minimum:

```gitignore
# Terraform working directory
.terraform/

# Terraform state
*.tfstate
*.tfstate.*

# Terraform plan files
*.tfplan

# Variable files that may contain secrets
*.tfvars
*.tfvars.json

# Crash logs
crash.log
crash.*.log

# Local override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# SSH private keys
*.pem
*.key

# Editor / OS files
.vscode/
.DS_Store
Thumbs.db
```

The `.terraform.lock.hcl` file should normally remain under source control.

---

# Infrastructure Cleanup

One major benefit of Infrastructure as Code is reproducibility.

After completing the lab, the environment can be removed:

```bash
terraform plan -destroy
terraform destroy
```

This removes the Azure infrastructure while preserving the Terraform source code.

Therefore:

```text
Terraform Code
     │
     ├──── apply ────> Create Infrastructure
     │
     └──── destroy ──> Remove Infrastructure
```

The same environment can later be recreated from the Terraform configuration.

This is particularly useful for temporary learning and development environments where resources should not remain running and generate unnecessary cloud costs.

---

# Current Learning Progress

- [x] Install Terraform
- [x] Authenticate to Azure using Azure CLI
- [x] Configure AzureRM provider
- [x] Create Azure Resource Group
- [x] Understand Terraform resource addresses
- [x] Understand resource references
- [x] Understand implicit dependencies
- [x] Create Azure Virtual Network
- [x] Create multiple subnets
- [x] Create Network Security Group
- [x] Associate NSG with subnet
- [x] Create custom inbound security rule
- [x] Generate SSH key pair
- [x] Create network interface
- [x] Deploy Ubuntu Linux VM
- [x] Use Terraform outputs
- [x] Inspect Terraform state
- [x] Troubleshoot Azure platform image issue
- [x] Understand partial deployment recovery
- [x] Destroy lab infrastructure safely

---

# Next Learning Objectives

The next stages of the project will focus on making the Terraform configuration more reusable and closer to an enterprise implementation.

Planned topics include:

- Terraform variables
- `terraform.tfvars`
- Development/test/production environments
- Local values
- Terraform outputs
- Remote state using Azure Storage
- State locking
- Terraform modules
- Reusable network modules
- Reusable compute modules
- Secret management
- Azure identity and least privilege
- GitHub Actions
- Terraform CI/CD
- `terraform fmt` and `terraform validate` in pipelines
- Pull request based `terraform plan`
- Controlled infrastructure deployment
- AWS infrastructure using the same Terraform concepts

---

# Key Takeaways

The most important concepts learned during this first stage are:

1. Infrastructure can be defined and managed as code.
2. Terraform resource addresses are different from actual Azure resource names.
3. Resource references allow infrastructure components to depend on one another.
4. Terraform automatically constructs a dependency graph.
5. `terraform plan` should be reviewed before infrastructure changes are applied.
6. Terraform state connects configuration with real cloud infrastructure.
7. Terraform can recover from partially successful deployments.
8. Infrastructure can be reproduced instead of manually rebuilt.
9. Cloud resource identifiers such as VM image SKUs must be exact.
10. Temporary infrastructure can be safely destroyed after testing to control cloud costs.

---

## Future Direction

The long-term goal of this project is to progress from a basic Terraform lab into a reusable cloud infrastructure project incorporating:

```text
Terraform
    │
    ├── Azure
    │    ├── Networking
    │    ├── Security
    │    ├── Compute
    │    └── Identity
    │
    ├── Remote State
    │
    ├── Modules
    │
    ├── GitHub
    │
    └── CI/CD
         │
         └── GitHub Actions
```

After establishing these concepts in Azure, similar Terraform patterns will be explored using AWS to compare cloud implementations while retaining the same Infrastructure as Code principles.