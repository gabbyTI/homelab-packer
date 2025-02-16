# Packer Homelab

Automating VM template creation for **Proxmox** using **HashiCorp Packer**.

## Folder Structure

```bash
.
├── Proxmox
│   ├── credentials.pkr.hcl # Authentication parameters for proxmox
│   └── ubuntu-24-04 # template-name
│       ├── files
│       │   └── # files used in the template file
│       ├── http
│       │   ├── meta-data
│       │   └── user-data # used for unattended installations
│       └── template.pkr.hcl # main template file
├── README.md
└── packer_cache
    └── port
```

## Requirements

- **Proxmox VE**
- **HashiCorp Packer**
- **Proxmox API Token**
- **Cloud-Init**

## Setup

### Configure Credentials

1. Copy the example credentials file:
   `cp Proxmox/credentials.pkr.hcl.example Proxmox/credentials.pkr.hcl`
   
2. Edit `Proxmox/credentials.pkr.hcl` with your Proxmox API token and URL.

### Validate the Packer Template

Run the following command to validate your Packer template:

```
packer validate -var-file=Proxmox/credentials.pkr.hcl Proxmox/ubuntu-server-24-04-lts-noble-numbat/template.pkr.hcl
```

### Build the VM Template

Run the following command to build the VM template:

```
packer build -var-file=Proxmox/credentials.pkr.hcl Proxmox/ubuntu-server-24-04-lts-noble-numbat/template.pkr.hcl
```