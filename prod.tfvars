resource_group_name = "tf-prod-rg"

location    = "Japan East"
environment = "Production"

vnet_address_space = [
  "10.20.0.0/16"
]

management_subnet_prefix = [
  "10.20.1.0/24"
]

application_subnet_prefix = [
  "10.20.2.0/24"
]