#!/bin/bash
# Ariel S. Weher <ariel[at]weher.net>
# https://weher.net

# Check if ethtool is installed
if ! command -v ethtool &> /dev/null; then
  echo "ERROR: ethtool is not installed."
  exit 1
fi

# Destination directory for .link files
link_dir="/etc/systemd/network"
mkdir -p ${link_dir}

# Mapping file
mapping_file="/tmp/mapping.txt"
echo > $mapping_file

# Regexp to exclude virtual ifaces
exclude_regex='^(lo|virbr|vnet|vmnet|tap|vlan|vmbr|vxlan|wt|bonding_masters)'

# tmp arrays
declare -A interface_info
declare -A mac_to_speed
declare -A mac_to_interface

# Get interface info
for interface in $(ls /sys/class/net | grep -vE "${exclude_regex}"); do
  mac_address=$(cat /sys/class/net/${interface}/address)
  current_speed=$(cat /sys/class/net/${interface}/speed 2>/dev/null || echo "Unknown")
  ethtool_output=$(ethtool ${interface})

  clear
  echo -e "\033[1mInterface: $interface\033[0m"
  echo -e "\033[1mMAC Address: $mac_address\033[0m"
  echo -e "\033[1mCurrent Speed: ${current_speed}Mbps\033[0m"
  echo -e "\033[1methtool output:\033[0m"
  echo "$ethtool_output"
  echo

  while true; do
    echo "What type of interface is this?"
    echo "1) 1Gbps"
    echo "2) 10Gbps"
    echo "3) 40Gbps"
    echo "4) 100Gbps"
    echo "9) Ignore interface $interface"
    read -p "Choose an option [1-5]: " speed_choice

    case $speed_choice in
      1) speed="1000"; break ;;
      2) speed="10000"; break ;;
      3) speed="40000"; break ;;
      4) speed="100000"; break ;;
      9) echo "Ignoring $interface."; break ;;
      *) echo "Invalid option. Please try again." ;;
    esac
  done

  if [[ $speed_choice != 5 ]]; then
    mac_to_speed["$mac_address"]=$speed
    mac_to_interface["$mac_address"]=$interface
  fi
done

# Create .link files
create_link_files() {
  local speed=$1
  local prefix=$2
  local idx=0

  # Sort MAC addresses
  for mac in $(echo "${!mac_to_speed[@]}" | tr ' ' '\n' | grep -v "^$" | sort); do
    if [[ "${mac_to_speed[$mac]}" == "$speed" ]]; then
      interface="${mac_to_interface[$mac]}"
      new_name="${prefix}${idx}"
      echo "Creating ${link_dir}/10-${new_name}.link for $interface with MAC $mac"
      # Create mapping file
      echo "$interface $new_name" >> $mapping_file
      cat <<EOF > "${link_dir}/10-${new_name}.link"
# Original interface name: $interface
[Match]
MACAddress=$mac

[Link]
Name=$new_name
EOF
      ((idx++))
    fi
  done
}

# Create files for each link type
create_link_files "1000" "eng"
create_link_files "10000" "teng"
create_link_files "40000" "feng"
create_link_files "100000" "heng"

echo "Files created."
ls -la $link_dir
echo
echo "Mapping file created."
cat $mapping_file
echo