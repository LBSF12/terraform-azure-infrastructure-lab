# Azure Infrastructure as Code with Terraform

## Overview

This repository documents my hands-on learning journey with Infrastructure as Code (IaC) using Terraform and Microsoft Azure.

The goal is not only to deploy Azure resources, but also to understand the core concepts behind Terraform, including:

- Infrastructure as Code
- Terraform providers
- Resources and resource references
- Terraform state
- Desired state
- `terraform init`, `plan`, `apply`, and `destroy`
- Azure networking
- Variables and outputs
- Terraform modules
- Remote state
- Infrastructure security
- Git and GitHub integration
- CI/CD for infrastructure

The lab will progressively evolve from a simple Azure Resource Group into a more complete cloud infrastructure environment.

---

## Architecture

### Current Architecture

```text
Azure Subscription
       |
       |
       +-- Resource Group
             |
             +-- tf-learning-rg