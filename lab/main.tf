terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://terraform@192.168.0.217/system?sshauth=privkey&keyfile=/Users/andres/.ssh/id_rsa"
}

variable "master_count" {
  default = 3
}
variable "node_count" {
  default = 3
}
resource "libvirt_volume" "disk_master" {
  count = var.master_count
  name = "k8s-master-${count.index + 1}.qcow2"
  pool = "default"
  size = 11474836480 # 20 GiB
}
resource "libvirt_volume" "disk_node" {
  count = var.node_count
  name = "k8s-node-${count.index + 1}.qcow2"
  pool = "default"
  size = 21474836480 # 20 GiB
}


resource "libvirt_domain" "k8s-master" {
  count  = var.master_count
  name   = "k8s-master-${count.index + 1}"
  memory = 3072
  vcpu   = 2

  network_interface {
    network_name   = "default"
    hostname       = "k8s-master-${count.index + 1}"
    wait_for_lease = false
  }
  disk {
    file = "/var/lib/libvirt/images/k8s-master-${count.index + 1}.qcow2"
  }

  xml {
    xslt = <<EOF
    <xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="yes"/>
      <!-- Cambiamos type y machine -->
      <xsl:template match="domain">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="type">qemu</xsl:attribute>
          <xsl:apply-templates select="node()"/>
        </xsl:copy>
      </xsl:template>
      <xsl:template match="os/type">
        <xsl:copy>
          <xsl:attribute name="arch">x86_64</xsl:attribute>
          <xsl:attribute name="machine">pc-q35-6.2</xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:copy>
      </xsl:template>
      <xsl:template match="@*|node()">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    EOF
  }
}

resource "libvirt_domain" "k8s-node" {
  count  = var.node_count
  name   = "k8s-node-${count.index + 1}"
  memory = 3072
  vcpu   = 2

  network_interface {
    network_name   = "default"
    hostname       = "k8s-node-${count.index + 1}"
    wait_for_lease = false
  }
  disk {
    file = "/var/lib/libvirt/images/k8s-node-${count.index + 1}.qcow2"
  }

  xml {
    xslt = <<EOF
    <xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="yes"/>
      <!-- Cambiamos type y machine -->
      <xsl:template match="domain">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="type">qemu</xsl:attribute>
          <xsl:apply-templates select="node()"/>
        </xsl:copy>
      </xsl:template>
      <xsl:template match="os/type">
        <xsl:copy>
          <xsl:attribute name="arch">x86_64</xsl:attribute>
          <xsl:attribute name="machine">pc-q35-6.2</xsl:attribute>
          <xsl:value-of select="."/>
        </xsl:copy>
      </xsl:template>
      <xsl:template match="@*|node()">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:template>
    </xsl:stylesheet>
    EOF
  }
}