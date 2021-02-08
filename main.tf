# main.tf

terraform {
  required_version = ">= 0.14.0"
}

#------------------------------------------------------------------------------
# LIBVIRT PROVIDER
#
# https://github.com/dmacvicar/terraform-provider-libvirt
#------------------------------------------------------------------------------

provider "libvirt" {
  uri = var.libvirt_server
}

#------------------------------------------------------------------------------
# NETWORK
#
# Provide a segmented network on libvirt for the windows lab
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/network.markdown
#------------------------------------------------------------------------------

resource "libvirt_network" "windows_lab_network" {
  name      = "windows_lab_network"
  addresses = [var.network_cidr_block]
  dns {
    enabled    = true
    local_only = false
    forwarders {
      address = "10.0.10.100"
    }
  }
  # This is a workaround - https://www.redhat.com/archives/libvirt-users/2018-April/msg00039.html
  # We can't set an IP on a (libvirt) domain - but we can create a static lease in DHCP for a given box
  # There's parameter for this with the libvirt provider - so we're using the xml transforms to perform this
  xml {
    xslt = file("xslt/network.xsl")
  }
}

#------------------------------------------------------------------------------
# Local images
#
# Load base images for lab machines
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/volume.html.markdown
#------------------------------------------------------------------------------

# Win10 image
resource "libvirt_volume" "win10-qcow2" {
  name   = "windows-10.qcow2"
  pool   = var.libvirt_storage_pool
  source = var.iso_win10
  format = "qcow2"
}

# Server 2019 image
resource "libvirt_volume" "win2019-qcow2" {
  name   = "windows-server-2019.qcow2"
  pool   = var.libvirt_storage_pool
  source = var.iso_win2019
  format = "qcow2"
}

# Kali image
resource "libvirt_volume" "kali-qcow2" {
  name   = "kali.qcow2"
  pool   = var.libvirt_storage_pool
  source = var.iso_kali
  format = "qcow2"
}

#------------------------------------------------------------------------------
# Windows Images
#
# Spin up windows machines
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/volume.html.markdown
#------------------------------------------------------------------------------

# windows 10
resource "libvirt_volume" "lab-win10" {
  name           = "lab-win10-${count.index}"
  base_volume_id = libvirt_volume.win10-qcow2.id
  pool           = "default"
  count          = var.count_win10_machines
}

resource "libvirt_domain" "domain-windows10" {
  depends_on = [libvirt_network.windows_lab_network, libvirt_domain.domain-windows-server-2019-pdc]
  name       = "lab-win10-${count.index}"
  memory     = 4096
  count      = var.count_win10_machines
  vcpu       = 2
  cpu = {
    mode = "host-passthrough"
  }

  network_interface {
    wait_for_lease = true
    hostname       = "win10-${count.index}"
    network_name   = "windows_lab_network"
  }

  disk {
    volume_id = element(libvirt_volume.lab-win10.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  console {
    type        = "spicevmc"
    target_type = "virtio"
    target_port = "org.qemu.guest_agent.0"

  }

  video {
    type = "virtio"
  }

  connection {
    type     = "winrm"
    user     = "vagrant"
    password = "vagrant"
    host     = self.network_interface.0.addresses.0
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i \"${self.network_interface.0.addresses.0},\" ansible/workstation-init-playbook.yml --extra-vars \"hostname=win10-${count.index}\""
  }

  xml {
    xslt = file("xslt/evtouch.xsl")
  }
}

# Windows Server 2019 (PDC)
resource "libvirt_volume" "lab-win2019-pdc" {
  name           = "lab-win2019-pdc"
  base_volume_id = libvirt_volume.win2019-qcow2.id
  pool           = "default"
}

resource "libvirt_domain" "domain-windows-server-2019-pdc" {
  depends_on = [libvirt_network.windows_lab_network]
  name       = "lab-winserver-2019-pdc"
  memory     = 1024
  vcpu       = 2
  cpu = {
    mode = "host-passthrough"
  }

  network_interface {
    wait_for_lease = true
    hostname       = "win2019-pdc"
    network_name   = "windows_lab_network"
    # see  "libvirt_network" "windows_lab_network" for why this is here
    mac = "AA:BB:CC:11:22:22"
  }

  disk {
    volume_id = libvirt_volume.lab-win2019-pdc.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  video {
    type = "virtio"
  }

  connection {
    type     = "winrm"
    user     = "vagrant"
    password = "vagrant"
    host     = self.network_interface.0.addresses.0
  }

  xml {
    xslt = file("xslt/evtouch.xsl")
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i \"${self.network_interface.0.addresses.0},\" ansible/pdc-init-playbook.yml"
  }

}

# Windows Server 2019
resource "libvirt_volume" "lab-win2019" {
  name           = "lab-win2019-${count.index}"
  base_volume_id = libvirt_volume.win2019-qcow2.id
  pool           = "default"
  count          = var.count_win2019_machines
}

resource "libvirt_domain" "domain-windows-server-2019" {
  depends_on = [libvirt_network.windows_lab_network, libvirt_domain.domain-windows-server-2019-pdc]
  name       = "lab-winserver-2019-${count.index}"
  memory     = 2048
  count      = var.count_win2019_machines
  vcpu       = 2
  cpu = {
    mode = "host-passthrough"
  }

  network_interface {
    wait_for_lease = true
    hostname       = "win2019-${count.index}"
    network_name   = "windows_lab_network"
  }

  disk {
    volume_id = element(libvirt_volume.lab-win2019.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  video {
    type = "virtio"
  }

  connection {
    type     = "winrm"
    user     = "vagrant"
    password = "vagrant"
    host     = self.network_interface.0.addresses.0
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i \"${self.network_interface.0.addresses.0},\" ansible/workstation-init-playbook.yml --extra-vars \"hostname=win2019-${count.index}\""
  }

  xml {
    xslt = file("xslt/evtouch.xsl")
  }
}

# Kali box
resource "libvirt_volume" "lab-kali" {
  name           = "lab-kali-${count.index}"
  base_volume_id = libvirt_volume.kali-qcow2.id
  pool           = "default"
  count          = var.count_kali_machines
}

resource "libvirt_domain" "domain-kali" {
  depends_on = [libvirt_network.windows_lab_network, libvirt_domain.domain-windows-server-2019-pdc]
  name       = "lab-kali-${count.index}"
  memory     = 2048
  count      = var.count_kali_machines
  vcpu       = 1
  cpu = {
    mode = "host-passthrough"
  }

  network_interface {
    wait_for_lease = true
    hostname       = "kali-${count.index}"
    network_name   = "windows_lab_network"
  }

  disk {
    volume_id = element(libvirt_volume.lab-kali.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  video {
    type = "virtio"
  }

  connection {
    type     = "ssh"
    user     = "root"
    password = "vagrant"
    host     = self.network_interface.0.addresses.0
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i \"${self.network_interface.0.addresses.0},\" ansible/kali-init-playbook.yml"
  }
}
