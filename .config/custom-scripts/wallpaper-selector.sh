#!/bin/bash

WALLPAPER_DIR="$HOME/.config/wallpapers/"
LINK_PATH="$HOME/.current_wallpaper"

SELECTION=$(ls "$WALLPAPER_DIR" | rofi -dmenu -p " 🖼️ Wallpapers " -theme-str 'window {width: 400px;}')

if [ -n "$SELECTION" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTION"

    if [ -f "$FULL_PATH" ]; then
        ln -sf "$FULL_PATH" "$LINK_PATH"
        awww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-fps 60 --transition-duration 2
        wallust run "$FULL_PATH"
        notify-send "Wallpaper and Lockscreen updated" "$SELECTION"
    else
        notify-send "Error" "Selected image not found."
    fi
fi