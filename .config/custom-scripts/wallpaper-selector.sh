#!/bin/bash

WALLPAPER_DIR="$HOME/.config/wallpapers/"
LINK_PATH="$HOME/.current_wallpaper"
ROFI_THEME="$HOME/.config/rofi/themes/wallpaper-select.rasi"

list_wallpapers() {
    cd "$WALLPAPER_DIR"
    for file in *; do
        if [[ "$file" =~ \.(jpg|jpeg|png|gif|webp)$ ]]; then
            echo -en "$file\0icon\x1f$WALLPAPER_DIR/$file\n"
        fi
    done
}

SELECTION=$(list_wallpapers | rofi -dmenu -theme "$ROFI_THEME")

if [ -n "$SELECTION" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTION"

    if [ -f "$FULL_PATH" ]; then
        ln -sf "$FULL_PATH" "$LINK_PATH"
        awww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-fps 60 --transition-duration 2
        wallust run "$FULL_PATH"
	killall -SIGUSR2 waybar

        notify-send "Wallpaper updated" "$SELECTION"
    else
        notify-send "Error" "Selected image not found."
    fi
fi
