#!/bin/bash

# Function to handle verbose output
verbose=false
if [[ "$1" == "-verbose" ]]; then
    verbose=true
    shift
fi

# Function to configure a remote server
configure_server() {
    server=$1
    name=$2
    ip=$3
    host_name=$4
    host_ip=$5

    # Transfer the configure-host.sh script to the remote server
    scp configure-host.sh remoteadmin@$server:/root
    if [ $? -ne 0 ]; then
        echo "Error with SCP to $server"
        exit 1
    fi

    # Execute the configure-host.sh script on the remote server
    ssh remoteadmin@$server "bash /root/configure-host.sh -name $name -ip $ip -hostentry $host_name $host_ip ${verbose:+-verbose}"
    if [ $? -ne 0 ]; then
        echo "Error with SSH to $server"
        exit 1
    fi
}

# Configure the servers
configure_server server1-mgmt loghost 192.168.16.3 webhost 192.168.16.4
configure_server server2-mgmt webhost 192.168.16.4 loghost 192.168.16.3

# Update local /etc/hosts file
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
