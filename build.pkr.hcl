variable "login_user" {
  type    = string
  default = "alex"
}

variable "login_pass" {
  type    = string
  default = "daedalus"
}

variable "local_ssh_public_key" {
  type    = string
  default = "/home/alex/.ssh/id_rsa.pub"
}

variable "root_pass" {
  type    = string
  default = "daedalus"
}

variable "output_img_size" {
  type    = number
  default = 4 * 1024 * 1024 * 1024
}

variable "hotspot_dev" {
  type    = string
  default = "wlan0"
}

variable "hotspot_ssid" {
  type    = string
  default = "Fenix"
}

variable "hotspot_pass" {
  type    = string
  default = "Macanache"
}

locals {
  image_home_dir = "/home/${var.login_user}"
}

source "arm-image" "armbian" {
  image_mounts      = ["/"]
  iso_checksum      = "sha256:f43e88596e736f44d72ed7ad98de447405bf908739d5981fdb36293fd3e295ec"
  iso_url           = "https://armbian.hosthatch.com/archive/orangepizeroplus2-h5/archive/Armbian_21.08.1_Orangepizeroplus2-h5_buster_current_5.10.60.img.xz"
  iso_target_path   = "./Armbian.img"
  qemu_binary       = "qemu-aarch64-static"
  target_image_size = var.output_img_size
}

build {
  sources = ["source.arm-image.armbian"]

  provisioner "shell" {
    inline = [
      "rm -f /etc/systemd/system/getty@.service.d/override.conf",
      "rm -f /etc/systemd/system/serial-getty@.service.d/override.conf",
      "rm -r /root/.not_logged_in_yet",
      "echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list",
      "curl -sL https://deb.nodesource.com/setup_16.x | bash -",
      "apt-get --allow-releaseinfo-change update",
      "apt-get upgrade -y",
      "apt-get install -y build-essential cmake rustc-mozilla cargo-mozilla python3 python3-dev python3-pip python3-venv libffi-dev git libusb-1.0-0-dev pkg-config dnsmasq-base avahi-daemon tmux can-utils nodejs libnss-mdns avahi-utils libavahi-compat-libdnssd-dev xsltproc libxml2-utils",
      "apt install -y -t buster-backports cockpit",
      "npm install -g npm@latest",
      "npm install -g signalk-server",
      "/usr/sbin/useradd -m -r signalk",
      "/usr/sbin/useradd -p '${var.login_pass}' -s /usr/bin/zsh -m ${var.login_user}",
      "echo '${var.login_user}     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers",
      "(echo '${var.root_pass}'; echo '${var.root_pass}';) | passwd root",
      "mkdir -p /root/.ssh",
      "/usr/sbin/usermod -s /usr/bin/zsh root"
    ]
  }

  provisioner "file" {
    source      = pathexpand(var.local_ssh_public_key)
    destination = "/root/.ssh/authorized_keys"
  }

  provisioner "file" {
    direction   = "download"
    source      = "/boot/armbianEnv.txt"
    destination = "tmp/armbianEnv.txt.orig"
  }

  provisioner "shell-local" {
    command = "sed -f provision/dt-overlays.sed < tmp/armbianEnv.txt.orig > tmp/armbianEnv.txt"
  }

  provisioner "file" {
    direction   = "upload"
    generated   = true
    source      = "tmp/armbianEnv.txt"
    destination = "/boot/armbianEnv.txt"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/blacklist-rtlsdr.conf"
    destination = "/etc/modprobe.d/blacklist-rtlsdr.conf"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/sun50i-h5-mcp2515.dts"
    destination = "/root/sun50i-h5-mcp2515.dts"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/kplex.conf"
    destination = "/etc/kplex.conf"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/can0.ifconfig"
    destination = "/etc/network/interfaces.d/can0"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/kplex.service"
    destination = "/etc/systemd/system/kplex.service"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/rtl-ais.service"
    destination = "/etc/systemd/system/rtl-ais.service"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/signalk-service.service"
    destination = "/etc/systemd/system/signalk-service.service"
  }

  provisioner "file" {
    direction   = "upload"
    source      = "provision/reload-rtlmod.service"
    destination = "/etc/systemd/system/reload-rtlmod.service"
  }

  provisioner "shell" {
    inline = [
      "pip3 install -U pip",
      "pip3 install -U setuptools",
      "pip3 install -U wheel",
      "pip3 install -U esptool",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo armbian-add-overlay /root/sun50i-h5-mcp2515.dts",
      # "systemctl enable rtl-ais.service",
      # "systemctl enable kplex.service",
      "systemctl enable signalk-service.service",
      "systemctl enable reload-rtlmod.service",
      "systemctl set-default multi-user.target",
    ]
  }

  provisioner "shell" {
    inline = [
      # "nmcli con add type wifi ifname ${var.hotspot_dev} con-name Hostspot autoconnect yes ssid '${var.hotspot_ssid}' 802-11-wireless.mode ap ipv4.method shared wifi-sec.key-mgmt wpa-psk wifi-sec.psk '${var.hotspot_pass}'",
      "",
    ]
  }

  provisioner "shell" {
    scripts = [
      "provision/build-from-src.sh",
    ]
  }
}
