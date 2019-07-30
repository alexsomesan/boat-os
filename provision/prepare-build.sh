#!/bin/sh

apt-get --allow-releaseinfo-change update
apt-get upgrade -y
apt-get install -y build-essential cmake python-pip git libusb-1.0-0-dev pkg-config dnsmasq-base avahi-daemon tmux

systemctl set-default multi-user.target
systemctl enable avahi-daemon.service
systemctl enable rtl-ais.service
systemctl enable kplex.service
