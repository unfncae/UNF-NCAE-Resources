#!/bin/bash
"""
This script was designed by Bombenheimer(Bruce) as part of the NCAE competition.

Follow me on GitHub for more projects like these and to collaborate!

https://github.com/Bombenheimer/

"""
shred_malware() {
    local file
    find / -type f -name 'Malicious File' 2>/dev/null | while read -r file; do
        echo "Shredding $file"
        shred -ufvz -n 3 "$file"
    done
}

shred_malware

echo "Shredding completed." 
