#!/bin/bash

# Get the network interface (e.g., eth0, wlan0)
# You might need to adjust this based on your actual interface name
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "N/A"
    exit 1
fi

# Get RX and TX bytes from /proc/net/dev using awk
RX_BYTES=$(grep "$INTERFACE" /proc/net/dev | awk '{print $2}')
TX_BYTES=$(grep "$INTERFACE" /proc/net/dev | awk '{print $10}')

# Store previous values
PREV_RX_BYTES=$(cat /tmp/polybar_prev_rx_bytes 2>/dev/null || echo 0)
PREV_TX_BYTES=$(cat /tmp/polybar_prev_tx_bytes 2>/dev/null || echo 0)

# Calculate difference
DIFF_RX=$((RX_BYTES - PREV_RX_BYTES))
DIFF_TX=$((TX_BYTES - PREV_TX_BYTES))

# Save current values for next iteration
echo "$RX_BYTES" > /tmp/polybar_prev_rx_bytes
echo "$TX_BYTES" > /tmp/polybar_prev_tx_bytes

# Get time difference (assuming script runs every 1 second)
# If Polybar interval is different, adjust this
TIME_DIFF=1

# Calculate speeds in KB/s
RX_SPEED=$((DIFF_RX / 1024 / TIME_DIFF))
TX_SPEED=$((DIFF_TX / 1024 / TIME_DIFF))

# Format output
if (( RX_SPEED > 1024 || TX_SPEED > 1024 )); then
    RX_SPEED_MB=$(echo "scale=1; $RX_SPEED / 1024" | bc)
    TX_SPEED_MB=$(echo "scale=1; $TX_SPEED / 1024" | bc)
    echo " ${RX_SPEED_MB}MB/s  ${TX_SPEED_MB}MB/s"
else
    echo " ${RX_SPEED}KB/s  ${TX_SPEED}KB/s"
fi