#!/usr/bin/env bash

STATE_FILE="${XDG_RUNTIME_DIR:-/run/user/${UID:-1000}}/kdedimmer_state"
MAX_DIM=95
STEP=5

ensure_daemon() {
    if ! pgrep -x "kdedimmer" >/dev/null 2>&1; then
        kdedimmer >/dev/null 2>&1 &
        # Wait until D-Bus interface is ready (up to 1 second)
        for _ in {1..20}; do
            if qdbus6 org.kde.kdedimmer /Dimmer >/dev/null 2>&1; then
                break
            fi
            sleep 0.05
        done
    fi
}

get_dim() {
    [ -f "$STATE_FILE" ] && cat "$STATE_FILE" || echo 0
}

show_osd() {
    local text="$1"
    qdbus6 org.kde.plasmashell /org/kde/osdService org.kde.osdService.showText "weather-clear-night" "$text" 2>/dev/null
}

ACTION="$1"
DIM=$(get_dim)

case "$ACTION" in
    down|more)
        # Start daemon lazily on demand
        ensure_daemon
        
        NEW_DIM=$((DIM + STEP))
        [ "$NEW_DIM" -gt "$MAX_DIM" ] && NEW_DIM="$MAX_DIM"
        
        echo "$NEW_DIM" > "$STATE_FILE"
        kdedimmer on >/dev/null 2>&1
        kdedimmer set "$NEW_DIM" >/dev/null 2>&1
        show_osd "Extra Dim: ${NEW_DIM}%"
        ;;
    up|less)
        if [ "$DIM" -gt 0 ]; then
            NEW_DIM=$((DIM - STEP))
            if [ "$NEW_DIM" -le 0 ]; then
                rm -f "$STATE_FILE"
                kdedimmer off >/dev/null 2>&1
                kdedimmer set 0 >/dev/null 2>&1
                show_osd "Extra Dim: Off"
            else
                echo "$NEW_DIM" > "$STATE_FILE"
                kdedimmer set "$NEW_DIM" >/dev/null 2>&1
                show_osd "Extra Dim: ${NEW_DIM}%"
            fi
        else
            rm -f "$STATE_FILE"
            kdedimmer off >/dev/null 2>&1
            kdedimmer set 0 >/dev/null 2>&1
            show_osd "Extra Dim: Off"
        fi
        ;;
    off)
        rm -f "$STATE_FILE"
        kdedimmer off >/dev/null 2>&1
        kdedimmer set 0 >/dev/null 2>&1
        show_osd "Extra Dim: Off"
        ;;
esac
