# Interface Rename Script

This script, located at proxmox8/interface-rename/interface-rename.sh, is used to rename network interfaces to stable ones.

Proxmox v8 sometimes changes the interfaces names on each reboot, which can be problematic for network configurations.

## This is the table of interface names this script uses

| Type                 | New name |
| -------------------- | -------- |
| Fast Ethernet        | enfX     |
| Gigabit Ethernet     | engX     |
| 10 Gigabit Ethernet  | tengX    |
| 25 Gigabit Ethernet  | twengX   |
| 40 Gigabit Ethernet  | fengX    |
| 100 Gigabit Ethernet | hengX    |

## How it works

The script first checks if ethtool is installed. If not, it exits with an error message.

You can install ethtool with the following command:

```bash
apt install -y ethtool
```

The script loops over each network interface, excluding certain types of virtual interfaces.
For each interface, it retrieves the MAC address and current speed, and stores the output of ethtool.

The script then prompts the user to specify the type of interface based on its speed (1Gbps, 10Gbps, 40Gbps, 100Gbps), or to ignore the interface.

Based on the user's choice, the script stores the speed and interface name associated with each MAC address.

This function creates .link files in the systemd directory for each interface of the specified speed, and creates a mapping file with the original and new names of each interface.

Then you can call the script `update-interfaces.sh` to update the file `/etc/network/interfaces` with the new interface names based in the mapping file generated before.
