#!/bin/bash
set -euo pipefail

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "❗ Run this script as root (sudo su -)"
  exit 1
fi

apt update && apt upgrade -y

apt install -y \
  live-build debootstrap qemu-user-static binfmt-support squashfs-tools xorriso \
  isolinux syslinux-utils grub-pc-bin grub-efi-amd64-bin grub-efi-arm64-bin \
  calamares curl xorg openbox lightdm chromium lxterminal \
  network-manager network-manager-gnome nm-connection-editor \
  zenity tor privoxy wget git \
  certbot python3-certbot-nginx python3-certbot-apache \
  e2fsprogs
