#!/usr/bin/env bash

# made by ani

polybar-msg cmd quit

echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar -c ~/.config/polybar/config.ini i3_bar 2>&1 | tee -a /tmp/polybar1.log & disown


echo "Bars launched..."
