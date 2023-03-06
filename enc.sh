#!/bin/bash

# Check if the script is being run on a Debian-based system
if [[ $(lsb_release -is) != "Debian" && $(lsb_release -is) != "Ubuntu" ]]
then
    echo "This script is only supported on Debian-based systems."
    exit
fi

# Check if shc is installed
if ! command -v shc &> /dev/null
then
    echo "shc is not installed. Please install it before running this script."
    exit
fi

# Create the ORY directory if it doesn't exist
if [[ ! -d /root/enc/ORY ]]
then
    mkdir /root/enc/ORY
fi

while true; do
    # Display menu options
    echo "Please choose an option:"
    echo "1. Encrypt files in /root/enc/"
    echo "2. Exit"

    read choice

    case $choice in
        1)
            # Loop through all files in /root/enc/
            for file in /root/enc/*
            do
              # Check if the file is a regular file (not a directory or symlink)
              if [[ -f $file ]]
              then
                # Copy the original file to /root/enc/ORY
                cp $file /root/enc/ORY/
                
                # Make the file executable
                chmod +x $file
                
                # Encrypt the file with shc and save it to a new file with the .x extension
                shc -f $file -o $file.x
                
                # Remove the original file
                rm $file
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
