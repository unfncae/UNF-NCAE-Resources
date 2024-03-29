#!/bin/bash

ls /etc/ssh
echo ""

cd /etc/ssh
typelist=("ecdsa" "rsa" "ed25519")

for file in *; do
    if [[ "$file" != "moduli" && "$file" != "sshd_config" && "$file" != "ssh_config" ]]; then
        rm -f "$file"
    fi
done

for type in "${typelist[@]}"; do
    ssh-keygen -t $type -f "./ssh_host_${type}_key" -N ""       
done

echo ""
ls /etc/ssh
