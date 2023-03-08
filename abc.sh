#!/bin/bash
clear

echo "Clients:"
awk '/^###/ {print NR".",$2,$3,$4}' "/root/ssh.txt"


read -p "Enter the number of the client to delete: " CLIENT_NUMBER

awk -v n="${CLIENT_NUMBER}" '/^###/ && NR==n {next} 1' "/root/ssh.txt" > "/root/ssh.txt.tmp"
mv "/root/ssh.txt.tmp" "/root/ssh.txt"

echo "Client deleted."
