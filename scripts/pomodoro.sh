#!/bin/bash

# made by ani
# This is my Pomodoro timer script. It helps me manage my work and break intervals. Stay focused, stay productive!

# I use these files to keep track of the timer's state and when it started. Gotta be persistent!
STATE_FILE="/tmp/polybar_pomodoro_state"
START_TIME_FILE="/tmp/polybar_pomodoro_start_time"

# My work and chill durations. I set work to 40 mins and chill to 20 mins. Feel free to adjust these to your own rhythm.
WORK_DURATION=$((40 * 60)) # 40 minutes in seconds
CHILL_DURATION=$((20 * 60)) # 20 minutes in seconds

# I initialize the state if the files don't exist or are empty. Starting fresh!
if [ ! -f "$STATE_FILE" ] || [ ! -s "$STATE_FILE" ] || [ ! -f "$START_TIME_FILE" ] || [ ! -s "$START_TIME_FILE" ]; then
    echo "work" > "$STATE_FILE"
    date +%s > "$START_TIME_FILE"
fi

# Grab the current state and start time.
CURRENT_STATE=$(cat "$STATE_FILE")
START_TIME=$(cat "$START_TIME_FILE")
CURRENT_TIME=$(date +%s)

# Calculate how much time has passed.
ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

# This is where the magic happens: I check the current state and switch if the time is up.
if [ "$CURRENT_STATE" == "work" ]; then
    REMAINING_TIME=$((WORK_DURATION - ELAPSED_TIME))
    if [ "$REMAINING_TIME" -le 0 ]; then
        # Time for a break! Switching to chill state.
        echo "chill" > "$STATE_FILE"
        date +%s > "$START_TIME_FILE"
        REMAINING_TIME=$CHILL_DURATION # Start chill countdown from full duration
        CURRENT_STATE="chill" # Update current state for immediate display
    fi
elif [ "$CURRENT_STATE" == "chill" ]; then
    REMAINING_TIME=$((CHILL_DURATION - ELAPSED_TIME))
    if [ "$REMAINING_TIME" -le 0 ]; then
        # Back to work! Time to get things done.
        echo "work" > "$STATE_FILE"
        date +%s > "$START_TIME_FILE"
        REMAINING_TIME=$WORK_DURATION # Start work countdown from full duration
        CURRENT_STATE="work" # Update current state for immediate display
    fi
fi

# Just making sure the remaining time doesn't go negative for display. No weird numbers on my bar.
if [ "$REMAINING_TIME" -lt 0 ]; then
    REMAINING_TIME=0
fi

# Format the remaining time into minutes and seconds. Looks cleaner this way.
MINUTES=$((REMAINING_TIME / 60))
SECONDS=$((REMAINING_TIME % 60))

# Ensure seconds always have two digits. Consistency is key.
printf -v FORMATTED_SECONDS "%02d" "$SECONDS"

# Finally, I output the current state and remaining time for Polybar to display.
if [ "$CURRENT_STATE" == "work" ]; then
    echo " WORK: ${MINUTES}:${FORMATTED_SECONDS}"
elif [ "$CURRENT_STATE" == "chill" ]; then
    echo " CHILL: ${MINUTES}:${FORMATTED_SECONDS}"
fi