#!/bin/bash
if ! dpkg -s iproute2 >/dev/null 2>&1; then
    echo "iproute2 package not found. Installing..."
    apt-get update && apt-get install -y iproute2
    if ! dpkg -s iproute2 >/dev/null 2>&1; then
        echo "Error: Failed to install iproute2. Exiting."
        exit 1
    fi
fi

while true; do
    # 192.168.22.0/24 via 192.168.2.226 dev eth1 
    # 192.168.32.0/24 via 192.168.2.226 dev eth1 

    # Example values:
    # subnets="192.168.22.0/24,192.168.32.0/24"
    # gateway="192.168.2.226"

    if [ -z "$subnets" ]; then
        echo "Error: subnets environment variable not set. Exiting."
        exit 1
    fi

    if [ -z "$gateway" ]; then
        echo "Error: gateway environment variable not set. Exiting."
        exit 1
    fi

    check_and_add_route() {
        local subnet="$1"
        current_route=$(ip route | grep "^$subnet " | awk '{print $3}')
        if [ -z "$current_route" ]; then
            ip route add "$subnet" via "$gateway"
        elif [ "$current_route" != "$gateway" ]; then
            ip route del "$subnet"
            ip route add "$subnet" via "$gateway"
        fi
    }

    IFS=',' read -ra subnet_array <<< "$subnets"
    for subnet in "${subnet_array[@]}"; do
        check_and_add_route "$subnet"
    done

    sleep 60
done