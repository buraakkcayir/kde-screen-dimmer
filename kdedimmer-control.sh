#!/usr/bin/env bash

set -u

STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
STATE_FILE="$STATE_DIR/kdedimmer_state"
MAX_DIM=95
STEP=5

die() {
    printf 'kdedimmer-control: %s\n' "$1" >&2
    exit 1
}

usage() {
    printf 'Usage: %s {down|more|up|less|off}\n' "${0##*/}" >&2
    exit 2
}

check_dependencies() {
    local command
    for command in kdedimmer qdbus6 pgrep; do
        command -v "$command" >/dev/null 2>&1 ||
            die "required command not found: $command"
    done
}

check_state_dir() {
    [ -d "$STATE_DIR" ] || die "runtime directory does not exist: $STATE_DIR"
    [ -w "$STATE_DIR" ] || die "runtime directory is not writable: $STATE_DIR"
    [ ! -L "$STATE_FILE" ] || die "refusing to use a symbolic-link state file"
}

write_dim() {
    local temporary_file
    temporary_file=$(mktemp "$STATE_DIR/kdedimmer_state.XXXXXX") ||
        die "could not create a temporary state file"
    chmod 600 "$temporary_file" ||
        die "could not secure the temporary state file"
    printf '%s\n' "$1" > "$temporary_file" ||
        die "could not write the state file"
    mv -f "$temporary_file" "$STATE_FILE" ||
        die "could not replace the state file"
}

ensure_daemon() {
    if ! pgrep -x "kdedimmer" >/dev/null 2>&1; then
        kdedimmer >/dev/null 2>&1 &
        local daemon_pid=$!
        for _ in {1..20}; do
            if qdbus6 org.kde.kdedimmer /Dimmer >/dev/null 2>&1; then
                break
            fi
            sleep 0.05
        done
        kill -0 "$daemon_pid" >/dev/null 2>&1 ||
            die "kdedimmer failed to start"
    fi
    qdbus6 org.kde.kdedimmer /Dimmer >/dev/null 2>&1 ||
        die "kdedimmer D-Bus interface is not available"
}

set_dim() {
    kdedimmer set "$1" >/dev/null 2>&1 ||
        die "kdedimmer could not set dimming to ${1}%"
}

turn_off() {
    kdedimmer off >/dev/null 2>&1 ||
        die "kdedimmer could not turn dimming off"
    set_dim 0
}

remove_state() {
    [ ! -e "$STATE_FILE" ] || rm -f -- "$STATE_FILE" ||
        die "could not remove the state file"
}

validate_dim() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]] || die "invalid state value"
    [ "$value" -le "$MAX_DIM" ] || die "state value exceeds ${MAX_DIM}%"
}

get_dim() {
    local value=0
    if [ -e "$STATE_FILE" ]; then
        [ -f "$STATE_FILE" ] || die "state path is not a regular file"
        value=$(cat -- "$STATE_FILE") || die "could not read the state file"
        validate_dim "$value"
    fi
    printf '%s\n' "$value"
}

show_osd() {
    local text="$1"
    qdbus6 org.kde.plasmashell /org/kde/osdService \
        org.kde.osdService.showText "weather-clear-night" "$text" >/dev/null 2>&1 ||
        printf 'kdedimmer-control: warning: could not display KDE OSD\n' >&2
}

[ "$#" -eq 1 ] || usage
ACTION="$1"
case "$ACTION" in
    down|more|up|less|off) ;;
    *) usage ;;
esac
check_dependencies
check_state_dir
DIM=$(get_dim) || exit $?

case "$ACTION" in
    down|more)
        ensure_daemon
        NEW_DIM=$((DIM + STEP))
        [ "$NEW_DIM" -gt "$MAX_DIM" ] && NEW_DIM="$MAX_DIM"
        write_dim "$NEW_DIM"
        kdedimmer on >/dev/null 2>&1 ||
            die "kdedimmer could not turn dimming on"
        set_dim "$NEW_DIM"
        show_osd "Extra Dim: ${NEW_DIM}%"
        ;;
    up|less)
        if [ "$DIM" -gt 0 ]; then
            NEW_DIM=$((DIM - STEP))
            if [ "$NEW_DIM" -le 0 ]; then
                remove_state
                turn_off
                show_osd "Extra Dim: Off"
            else
                ensure_daemon
                write_dim "$NEW_DIM"
                set_dim "$NEW_DIM"
                show_osd "Extra Dim: ${NEW_DIM}%"
            fi
        else
            remove_state
            turn_off
            show_osd "Extra Dim: Off"
        fi
        ;;
    off)
        remove_state
        turn_off
        show_osd "Extra Dim: Off"
        ;;
esac
