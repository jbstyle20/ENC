#!/bin/bash

# CEK OS (DEBIAN ONLY)
if [[ $(lsb_release -is) != "Debian" && $(lsb_release -is) != "Ubuntu" ]]
then
    echo "This script is only supported on Debian-based systems."
    exit
fi

# CEK SHC 
if ! command -v shc &> /dev/null
then
    echo "shc is not installed. Installing shc..."
    sudo apt-get update
    sudo apt-get install shc
    echo "shc installed successfully."
    read -p "Press enter to continue..."
    ./shc.sh
fi

# BUAT FOLDER UNTUK BACKUP FILE ORY
if [[ ! -d /root/enc/ORY ]]
then
    mkdir /root/enc/ORY
fi

while true; do
    
    # MENU
    clear
    echo "Please choose an option:"
    echo "1. Encrypt files in /root/enc/"
    echo "2. Exit"

    read choice

    case $choice in
        1)
            # CEK FILE /root/enc
            for file in /root/enc/*
            do
              if [[ -f $file ]]
              then
                # BAKUP FILE ORY KE /root/enc/ORY
                cp $file /root/enc/ORY/
                
                # CHMOD FILE SEBELUM ENC
                chmod +x $file
                
                # ENC SEMUA FILE DI /root/enc
                shc -f $file -o $file.x
                
                # PADAM FILE ORY 
                rm $file
                
                # PADAM file.x.c
                rm $file.x.c
                
                # RENAME ENC FILE
                mv $file.x ${file%}
              fi
            done
            echo "Files encrypted."
            ;;
        2)
            echo "Exiting."
            exit
            ;;
        *)
            echo "Invalid option. Please choose 1 or 2."
            ;;
    esac
done
