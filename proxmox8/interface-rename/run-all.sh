#!/bin/bash
clear
wget -q https://raw.githubusercontent.com/aweher/proxmox-tools/main/proxmox8/interface-rename/interface-rename.sh -o /tmp/rename-interfaces.sh
wget -q https://raw.githubusercontent.com/aweher/proxmox-tools/main/proxmox8/interface-rename/update-interfaces.sh -o /tmp/update-interfaces.sh
echo "This script will modify your network interfaces."
echo "Press CTRL+C to exit, any other key to continue..."
read onekey
cd /tmp
bash rename-interfaces.sh && bash update-interfaces.sh
echo "Done. Changes will take effect after reboot."