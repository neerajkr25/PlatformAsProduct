# File: README.md
```md
# terraform-azure-vnet-module

A reusable Terraform module to create Azure Virtual Networks and dynamic subnets.

## Features
- Create or use an existing resource group
- Dynamic subnets with optional NSG / route table attachments and delegations
- Tags and DNS servers support
- Optional DDoS protection plan association

## Usage
See `examples/simple` for a minimal usage example. Import module using a relative path or publish to a registry.

## Notes & improvements
- This module deliberately keeps the VNet/subnet logic focused and simple. Consider adding:
  - CIDR overlap validation
  - Built-in NSG and route table creation options
  - Support for service endpoints in a richer way (delegations vs endpoints)
  - Optional diagnostics/flow logs

## License
MIT