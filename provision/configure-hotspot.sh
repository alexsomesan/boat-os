#!/bin/sh

systemctl start NetworkManager.service
nmcli con add type wifi ifname wlan0 con-name Hostspot autoconnect yes ssid "Fenix" 802-11-wireless.mode ap ipv4.method shared wifi-sec.key-mgmt wpa-psk wifi-sec.psk "Macanache"
nmcli con up Hostspot
