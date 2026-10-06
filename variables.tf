variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Azure Virtual Network"
  type        = list(string)
}

variable "management_subnet_prefix" {
  description = "Address prefix for the management subnet"
  type        = list(string)
}

variable "application_subnet_prefix" {
  description = "Address prefix for the application subnet"
  type        = list(string)
}