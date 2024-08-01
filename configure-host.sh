#!/bin/bash

# Function to log messages if verbose is enabled
log() {
  if [ "$VERBOSE" = true ]; then
    echo "$1"
  fi
}

# Initialize verbose flag
VERBOSE=false

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -verbose)
      VERBOSE=true
      shift
      ;;
    -name)
      NAME="$2"
      shift 2
      ;;
    -ip)
      IP="$2"
      shift 2
      ;;
    -hostentry)
      HOSTNAME="$2"
      HOSTIP="$3"
      shift 3
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Function to update hostname
update_hostname() {
  current_name=$(hostname)
  if [ "$current_name" != "$NAME" ]; then
    echo "$NAME" > /etc/hostname
    hostname "$NAME"
    sed -i "s/$current_name/$NAME/g" /etc/hosts
    log "Hostname updated to $NAME"
    logger "Hostname changed to $NAME"
  fi
}

# Function to update IP address
update_ip() {
  current_ip=$(hostname -I | awk '{print $1}')
  if [ "$current_ip" != "$IP" ]; then
    # Update /etc/hosts
    sed -i "s/$current_ip/$IP/g" /etc/hosts
    # Update netplan configuration (assuming Ubuntu with netplan)
    netplan_file="/etc/netplan/01-netcfg.yaml"
    if [ -f "$netplan_file" ]; then
      sed -i "s/$current_ip/$IP/g" "$netplan_file"
      netplan apply
    fi
    log "IP address updated to $IP"
    logger "IP address changed to $IP"
  fi
}

# Function to update /etc/hosts entry
update_hostentry() {
  if ! grep -q "$HOSTNAME" /etc/hosts; then
    echo "$HOSTIP $HOSTNAME" >> /etc/hosts
    log "Host entry added: $HOSTNAME $HOSTIP"
    logger "Host entry added: $HOSTNAME $HOSTIP"
  fi
}

# Apply configurations
if [ -n "$NAME" ]; then
  update_hostname
fi

if [ -n "$IP" ]; then
  update_ip
fi

if [ -n "$HOSTNAME" ] && [ -n "$HOSTIP" ]; then
  update_hostentry
fi
