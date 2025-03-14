#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Starting assignment2 script..."

# 1. Configure Network Interface
echo "Configuring the network interface..."
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

# Check if the network interface is already configured
if ! grep -q "192.168.16.21/24" "$NETPLAN_FILE"; then
    echo "Updating netplan configuration..."
    # Update netplan config for 192.168.16.21/24
    sudo sed -i '/ethernets:/a \    enp0s8:\n      dhcp4: false\n      addresses:\n        - 192.168.16.21/24' $NETPLAN_FILE
    sudo netplan apply
    echo "Network interface configured."
else
    echo "Network interface already configured."
fi

# 2. Modify /etc/hosts file
echo "Updating /etc/hosts file..."
if ! grep -q "192.168.16.21" /etc/hosts; then
    echo "192.168.16.21 server1" | sudo tee -a /etc/hosts
    echo "/etc/hosts file updated."
else
    echo "/etc/hosts file already contains the entry."
fi

# 3. Install required software (Apache2, Squid)
echo "Installing required software..."
if ! command_exists apache2; then
    sudo apt update && sudo apt install -y apache2
    echo "Apache2 installed."
else
    echo "Apache2 is already installed."
fi

if ! command_exists squid; then
    sudo apt update && sudo apt install -y squid
    echo "Squid proxy installed."
else
    echo "Squid proxy is already installed."
fi

# 4. Create users and add them to the sudo group
echo "Creating users..."

USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

for user in "${USERS[@]}"; do
    if ! id "$user" &>/dev/null; then
        sudo useradd -m -s /bin/bash "$user"
        sudo usermod -aG sudo "$user"
        echo "User $user created and added to sudo group."
    else
        echo "User $user already exists."
    fi
done

# 5. Add SSH keys to authorized_keys for each user
echo "Adding SSH keys for each user..."

# Dennis SSH keys
echo "Adding SSH keys for dennis..."
mkdir -p /home/dennis/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | sudo tee -a /home/dennis/.ssh/authorized_keys
sudo chown -R dennis:dennis /home/dennis/.ssh
sudo chmod 700 /home/dennis/.ssh
sudo chmod 600 /home/dennis/.ssh/authorized_keys

# Add public keys for other users (You'll need to adjust this to add the public keys for each user in the list)
for user in "${USERS[@]}"; do
    if [ "$user" != "dennis" ]; then
        echo "Adding SSH keys for $user..."
        mkdir -p /home/$user/.ssh
        # Example SSH key, replace with actual public key for each user
        echo "ssh-ed25519 example-public-key" | sudo tee -a /home/$user/.ssh/authorized_keys
        sudo chown -R $user:$user /home/$user/.ssh
        sudo chmod 700 /home/$user/.ssh
        sudo chmod 600 /home/$user/.ssh/authorized_keys
    fi
done

echo "Assignment2 script finished!"
