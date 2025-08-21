terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://root@192.168.0.141/system?sshauth=privkey&keyfile=/Users/andres/.ssh/id_rsa"
}

resource "libvirt_volume" "disk_master_1" {
  name = "k8s-master-1.qcow2"
  pool = "default"
  size = 21474836480 # 20 GiB
}

resource "libvirt_volume" "disk_master_2" {
  name = "k8s-master-2.qcow2"
  pool = "default"
  size = 21474836480 # 20 GiB
}

resource "libvirt_volume" "disk_master_3" {
  name = "k8s-master-3.qcow2"
  pool = "default"
  size = 21474836480 # 20 GiB
}

resource "libvirt_domain" "k8s-master-1" {
  name   = "k8s-master-1"
  memory = 3072
  vcpu   = 2
  disk {
    volume_id = libvirt_volume.disk_master_1.id
  }
}
resource "libvirt_domain" "k8s-master-2" {
  name   = "k8s-master-2"
  memory = 3072
  vcpu   = 2
  disk {
    volume_id = libvirt_volume.disk_master_2.id
  }
}
resource "libvirt_domain" "k8s-master-3" {
  name   = "k8s-master-3"
  memory = 3072
  vcpu   = 2
  disk {
    volume_id = libvirt_volume.disk_master_3.id
  }

}

