#!/bin/bash

# Function to handle signals (ignore TERM, HUP, and INT)
trap '' TERM HUP INT

# Default verbose flag (false)
verbose=false

# Function to log changes
log_change() {
    logger "$1"
    [ "$verbose" = true ] && echo "$1"
}

# Parse arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -verbose) verbose=true ;;
        -name) desired_name="$2"; shift ;;
        -ip) desired_ip="$2"; shift ;;
        -hostentry) host_name="$2"; host_ip="$3"; shift 2 ;;
        *) echo "Invalid argument: $1"; exit 1 ;;
    esac
    shift
done

# Check and update hostname
if [ -n "$desired_name" ]; then
    current_name=$(hostname)
    if [ "$current_name" != "$desired_name" ]; then
        log_change "Changing hostname from $current_name to $desired_name"
        echo "$desired_name" > /etc/hostname
        sed -i "s/$current_name/$desired_name/" /etc/hosts
        hostname "$desired_name"
    fi
fi

# Check and update IP address
if [ -n "$desired_ip" ]; then
    current_ip=$(hostname -I | awk '{print $1}')
    if [ "$current_ip" != "$desired_ip" ]; then
        log_change "Changing IP address from $current_ip to $desired_ip"
        # Modify /etc/netplan configuration (adjust according to your network config)
        sed -i "s/$current_ip/$desired_ip/" /etc/netplan/00-installer-config.yaml
        netplan apply
    fi
fi

# Update /etc/hosts with provided host and IP
if [ -n "$host_name" ] && [ -n "$host_ip" ]; then
    grep -q "$host_ip" /etc/hosts
    if [ $? -ne 0 ]; then
        log_change "Adding $host_name with IP $host_ip to /etc/hosts"
        echo "$host_ip $host_name" >> /etc/hosts
    fi
fi
