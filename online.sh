#!/bin/bash

# Define colors
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

# Clear output file
echo -n > /tmp/other.txt

# Get all user accounts
data=( $(grep '^###' /etc/xray/config.json | cut -d ' ' -f 2 | sort -u) )

# Display header
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;41;36m     XRAY Vmess WS User Login      \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Check if there are any users online
if [ ${#data[@]} -eq 0 ]; then
    echo "No users online"
else
    # Loop through each user account
    for akun in "${data[@]}"; do
        # Get list of unique IP addresses for this user
        data2=( $(grep -w "$akun" /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort -u) )

        # Loop through each IP address for this user
        count=1
        for ip in "${data2[@]}"; do
            # Check if this IP is associated with this user
            jum=$(grep -w "$akun" /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort -u)
            if [[ "$jum" = "$ip" ]]; then
                echo "$count. $jum" >> /tmp/ipvmess.txt
                ((count++))
            else
                echo "$ip" >> /tmp/other.txt
            fi
            # Remove IP addresses that have already been counted
            jum2=$(cat /tmp/ipvmess.txt)
            sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
        done

        # Check if there are any IP addresses associated with this user
        jum=$(cat /tmp/ipvmess.txt)
        if [[ -n "$jum" ]]; then
            jum2=$(cat /tmp/ipvmess.txt | nl)
            echo "User : $akun"
            echo "$jum2"
            echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        fi

        # Clear temporary files
        rm -f /tmp/ipvmess.txt
        rm -f /tmp/other.txt
    done
fi
echo ""
