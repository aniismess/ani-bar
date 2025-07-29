#!/bin/bash

# Rofi script to get custom pomodoro times

WORK=$(rofi -dmenu -p "Work time (minutes):" -theme-str 'window { background-color: #282c34; } element-text { color: #abb2bf; }')
if [ -z "$WORK" ]; then
    exit 0
fi

CHILL=$(rofi -dmenu -p "Chill time (minutes):" -theme-str 'window { background-color: #282c34; } element-text { color: #abb2bf; }')
if [ -z "$CHILL" ]; then
    exit 0
fi

/home/ani/.config/polybar/scripts/pomodoro.sh start $WORK $CHILL