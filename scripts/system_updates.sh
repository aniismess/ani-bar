#!/bin/bash

# made by ani
# This script checks for system updates.

# I use `checkupdates` to see how many packages need an upgrade. 
UPDATES=$(checkupdates 2>/dev/null | wc -l)

# If there are no updates, I show a green checkmark and a zero.
if [ "$UPDATES" -eq 0 ]; then
    echo " 0"
else
    echo " ${UPDATES}"
fi
