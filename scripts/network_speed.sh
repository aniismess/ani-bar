#!/bin/bash

# made by ani



# I grab the network interface. You might need to tweak this if your setup is weird.
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "N/A" # If no interface, I just say N/A. Simple.
    exit 1
fi

# I pull the raw byte counts from /proc/net/dev. This is where the magic happens.
RX_BYTES=$(grep "$INTERFACE" /proc/net/dev | awk '{print $2}')
TX_BYTES=$(grep "$INTERFACE" /proc/net/dev | awk '{print $10}')

PREV_RX_BYTES=$(cat /tmp/polybar_prev_rx_bytes 2>/dev/null || echo 0)
PREV_TX_BYTES=$(cat /tmp/polybar_prev_tx_bytes 2>/dev/null || echo 0)


DIFF_RX=$((RX_BYTES - PREV_RX_BYTES))
DIFF_TX=$((TX_BYTES - PREV_TX_BYTES))

# Save current values for the next round. Future me will thank me.
echo "$RX_BYTES" > /tmp/polybar_prev_rx_bytes
echo "$TX_BYTES" > /tmp/polybar_prev_tx_bytes

!
TIME_DIFF=1

# Calculate speeds in KB/s. Because I like my numbers clean.
RX_SPEED=$((DIFF_RX / 1024 / TIME_DIFF))
TX_SPEED=$((DIFF_TX / 1024 / TIME_DIFF))

# Format the output. If it's over 1MB/s, I show it in MB/s. Otherwise, KB/s. Keeps it readable.
if (( RX_SPEED > 1024 || TX_SPEED > 1024 )); then
    RX_SPEED_MB=$(echo "scale=1; $RX_SPEED / 1024" | bc)
    TX_SPEED_MB=$(echo "scale=1; $TX_SPEED / 1024" | bc)
    echo " ${RX_SPEED_MB}MB/s  ${TX_SPEED_MB}MB/s"
else
    echo " ${RX_SPEED}KB/s  ${TX_SPEED}KB/s"
fi
