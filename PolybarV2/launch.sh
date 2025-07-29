#!/usr/bin/env bash

# made by ani

# First, I gotta kill any old Polybar instances. No zombies on my desktop.
# If IPC is on, this is the clean way. I prefer clean.
polybar-msg cmd quit
# If things go sideways, this is the nuclear option. Sometimes you just gotta nuke it from orbit.
# killall -q polybar

# Now, launch my glorious bar! I'm piping output to a log, just in case things get weird.
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar -c ~/.config/polybar/config.ini i3_bar 2>&1 | tee -a /tmp/polybar1.log & disown

# A little confirmation, because I like to know my bars are doing their thing.
echo "Bars launched..."