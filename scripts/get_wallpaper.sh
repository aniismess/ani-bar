#!/bin/bash

# Get the current wallpaper path from pywal's cache
WALLPAPER_PATH=$(cat ~/.cache/wal/wal)

# Extract just the filename
FILENAME=$(basename "$WALLPAPER_PATH")

echo "$FILENAME"
