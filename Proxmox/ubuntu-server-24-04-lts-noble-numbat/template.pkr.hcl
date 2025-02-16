packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
  type = string
}
variable "proxmox_api_token_id" {
  type = string
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

# Sources
source "proxmox-iso" "ubuntu-server" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = false

  node                 = "pve"
  vm_id                = 8000
  vm_name              = "ubuntu-server-24-04-lts-noble-numbat"
  template_description = "Ubuntu Server 24.04 LTS Noble Numbat Release"

  boot_iso {
    type     = "scsi"
    iso_file = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
    unmount  = true
  }

  qemu_agent = true

  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "20G"
    format       = "qcow2"
    storage_pool = "vm-disks"
    type         = "scsi"
  }

  serials = ["socket"]

  cores  = 1
  memory = 2048

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # TODO: watch line 58
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  # Packer auto install settings
  http_directory = "C:/Users/gabri/Documents/DevOps/Packer/Proxmox/ubuntu-server-24-04-lts-noble-numbat/http"

  http_bind_address = "192.168.2.92"
  http_port_min     = 8803
  http_port_max     = 8803

  # TODO: watch these
  ssh_username = "gabriel"
  # ssh_password = "XXXXXX
  ssh_private_key_file = "~/.ssh/id_rsa"

  ssh_timeout = "30m"
  ssh_pty     = true
}

# Build
build {
  sources = ["source.proxmox-iso.ubuntu-server"]
  name    = "ubuntu-server-24-04-lts-noble-numbat"

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "C:/Users/gabri/Documents/DevOps/Packer/Proxmox/ubuntu-server-24-04-lts-noble-numbat/files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
}