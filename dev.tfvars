resource_group_name = "tf-dev-rg"

location    = "Japan East"
environment = "Development"

vnet_address_space = [
  "10.10.0.0/16"
]

management_subnet_prefix = [
  "10.10.1.0/24"
]

application_subnet_prefix = [
  "10.10.2.0/24"
]