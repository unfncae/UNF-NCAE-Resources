#!/bin/bash

# The new password to set for each user.
NEW_PASSWORD='YourNewPasswordHere'

# File to log the usernames for whom passwords were changed.
LOG_FILE='/var/log/password_reset.log'

# Optionally, specify a UID range for regular users (e.g., 1000-60000)
MIN_UID=1000
MAX_UID=60000

# Iterate over each user in the system.
getent passwd | while IFS=: read -r username password uid gid fullname homedir shell; do
    if [ "$uid" -ge "$MIN_UID" ] && [ "$uid" -le "$MAX_UID" ]; then
        echo "Changing password for $username ($uid)."
        echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | passwd "$username"
        if [ $? -eq 0 ]; then
            echo "$username: success" >> "$LOG_FILE"
        else
            echo "$username: failure" >> "$LOG_FILE"
        fi
    fi
done
