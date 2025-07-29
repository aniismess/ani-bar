#!/bin/bash

#!/bin/bash

# ─────────────────────────────
# POMODORO TIMER by ani (extended)
# ─────────────────────────────

STATE_FILE="/tmp/polybar_pomodoro_state"
START_TIME_FILE="/tmp/polybar_pomodoro_start_time"
PAUSED_FILE="/tmp/polybar_pomodoro_paused"
DURATIONS_FILE="/tmp/polybar_pomodoro_durations"

DEFAULT_WORK=2400   # 40 * 60
DEFAULT_CHILL=1200  # 20 * 60

# Handle input arguments
case "$1" in
    start)
        WORK_DURATION=${2:-40}
        CHILL_DURATION=${3:-20}
        echo "$((WORK_DURATION * 60)) $((CHILL_DURATION * 60))" > "$DURATIONS_FILE"
        echo "work" > "$STATE_FILE"
        date +%s > "$START_TIME_FILE"
        rm -f "$PAUSED_FILE"
        exit 0
        ;;
    toggle)
        if [ ! -f "$STATE_FILE" ]; then
            # Not running, so start with default durations
            echo "work" > "$STATE_FILE"
            date +%s > "$START_TIME_FILE"
            echo "$DEFAULT_WORK $DEFAULT_CHILL" > "$DURATIONS_FILE"
            rm -f "$PAUSED_FILE"
        elif [ -f "$PAUSED_FILE" ]; then
            # Resuming from pause
            PAUSED_DURATION=$(cat "$PAUSED_FILE")
            NEW_START=$(( $(date +%s) - PAUSED_DURATION ))
            echo "$NEW_START" > "$START_TIME_FILE"
            rm -f "$PAUSED_FILE"
        else
            # Pausing
            START_TIME=$(cat "$START_TIME_FILE")
            NOW=$(date +%s)
            echo $((NOW - START_TIME)) > "$PAUSED_FILE"
        fi
        exit 0
        ;;
    stop)
        rm -f "$STATE_FILE" "$START_TIME_FILE" "$PAUSED_FILE" "$DURATIONS_FILE"
        exit 0
        ;;
esac

# Load durations
if [ -f "$DURATIONS_FILE" ]; then
    read WORK_DURATION CHILL_DURATION < "$DURATIONS_FILE"
else
    WORK_DURATION=$DEFAULT_WORK
    CHILL_DURATION=$DEFAULT_CHILL
fi

# If state files don't exist, don't display anything
if [ ! -f "$STATE_FILE" ] || [ ! -s "$STATE_FILE" ] || [ ! -f "$START_TIME_FILE" ] || [ ! -s "$START_TIME_FILE" ]; then
    echo " Start"
    exit 0
fi

# Display pause state
if [ -f "$PAUSED_FILE" ]; then
    echo " PAUSED"
    exit 0
fi

# Read state and calculate
CURRENT_STATE=$(cat "$STATE_FILE")
START_TIME=$(cat "$START_TIME_FILE")
CURRENT_TIME=$(date +%s)
ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

if [ "$CURRENT_STATE" = "work" ]; then
    REMAINING_TIME=$((WORK_DURATION - ELAPSED_TIME))
    if [ "$REMAINING_TIME" -le 0 ]; then
        echo "chill" > "$STATE_FILE"
        date +%s > "$START_TIME_FILE"
        REMAINING_TIME=$CHILL_DURATION
        CURRENT_STATE="chill"
        dunstify -u normal "Pomodoro" "Work session is over! Time to chill."
    fi
elif [ "$CURRENT_STATE" = "chill" ]; then
    REMAINING_TIME=$((CHILL_DURATION - ELAPSED_TIME))
    if [ "$REMAINING_TIME" -le 0 ]; then
        echo "work" > "$STATE_FILE"
        date +%s > "$START_TIME_FILE"
        REMAINING_TIME=$WORK_DURATION
        CURRENT_STATE="work"
        dunstify -u normal "Pomodoro" "Chill session is over! Time to get back to work."
    fi
fi

# Format time
[ "$REMAINING_TIME" -lt 0 ] && REMAINING_TIME=0
MINUTES=$((REMAINING_TIME / 60))
SECONDS=$((REMAINING_TIME % 60))
printf -v FORMATTED_SECONDS "%02d" "$SECONDS"

# Output
if [ "$CURRENT_STATE" == "work" ]; then
    echo " WORK: ${MINUTES}:${FORMATTED_SECONDS}"
else
    echo " CHILL: ${MINUTES}:${FORMATTED_SECONDS}"
fi