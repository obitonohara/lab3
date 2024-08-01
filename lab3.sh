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
if [ "$1" == "-verbose" ]; then
  VERBOSE=true
  shift
fi

# Transfer and execute script on server1
log "Transferring configure-host.sh to server1-mgmt"
scp configure-host.sh remoteadmin@server1-mgmt:/root
if [ "$VERBOSE" = true ]; then
  ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 -verbose
else
  ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4
fi

# Transfer and execute script on server2
log "Transferring configure-host.sh to server2-mgmt"
scp configure-host.sh remoteadmin@server2-mgmt:/root
if [ "$VERBOSE" = true ]; then
  ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 -verbose
else
  ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3
fi

# Update local /etc/hosts file
log "Updating local /etc/hosts file"
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
