#!/usr/bin/env bash

# Check if scratchpad window exists in Hyprland
if ! hyprctl clients -j | jq -e '.[] | select(.class == "ghostty.scratchpad" or .class == "ghostty-scratchpad")' >/dev/null 2>&1; then
    setsid -f ghostty --class=ghostty.scratchpad >/dev/null 2>&1
    for i in {1..25}; do
        if hyprctl clients -j | jq -e '.[] | select(.class == "ghostty.scratchpad" or .class == "ghostty-scratchpad")' >/dev/null 2>&1; then
            break
        fi
        sleep 0.04
    done
fi

hyprctl dispatch 'hl.dsp.workspace.toggle_special("scratchpad")'
