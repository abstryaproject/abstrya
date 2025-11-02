#!/system/bin/sh
set -euo pipefail
IFS=$'\n\t'

sudo apt update
sudo apt install -y live-build debootstrap qemu-user-static binfmt-support squashfs-tools xorriso isolinux syslinux-utils grub-pc-bin grub-efi-amd64-bin grub-efi-arm64-bin calamares curl chattr xorg openbox lightdm chromium-browser lxterminal network-manager network-manager-gnome nm-connection-editor zenity tor privoxy wget git certbot python3-certbot-nginx python3-certbot-apache
