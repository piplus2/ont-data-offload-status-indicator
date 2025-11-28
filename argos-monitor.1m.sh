#!/usr/bin/env bash
# Author: Paolo Inglese
# Description: Argos script to monitor ont-platform-data-offload service
# Shows active rsync transfers and allows quick actions
# Requirements: Argos (https://github.com/p-e-w/argos)

# Setup:
# 1. Save this script as argos-monitor.1m.sh in $HOME/.config/argos/
# 2. Make it executable: chmod +x $HOME/.config/argos/argos-monitor.1m.sh
# 3. Ensure ont-platform-data-offload service is installed and running
# 4. (Optional) Adjust SERVICE_NAME and LOG_FILE variables below if needed

# CONFIGURATION

# Name of the offload service to monitor
SERVICE_NAME="ont-platform-data-offload"
# This file stores the previous count of active transfers to detect new
# activity.
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/ont-offload-state"

# Log file path - This is optional, if present it allows quick access to recent logs
# from the menu.
LOG_FILE="/data/data-offload.log"

# ICONS
ICON_IDLE="⚪"
ICON_SYNC="🟢"
ICON_ERR="🔴"

# Service Status Check

if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$ICON_ERR Offload Down | color=red"
    echo "---"
    echo "Start Service | bash='gnome-terminal -- bash -c \"sudo systemctl start $SERVICE_NAME; read -p \"Press Enter...\"\"' terminal=false"
    echo "View Logs | bash='gnome-terminal -- journalctl -u $SERVICE_NAME -f' terminal=false"
    exit 0
fi

# Find Main PID of the service - this will determine if the service is running
MAIN_PID=$(pgrep -f "ont-platform-data-offload" | head -n 1)

if [[ -z "$MAIN_PID" ]]; then
     echo "$ICON_ERR Ghost | color=orange"
     echo "---"
     echo "Service active but PID missing."
     echo "Restart | bash='gnome-terminal -- bash -c \"sudo systemctl restart $SERVICE_NAME\"' terminal=false"
     exit 0
fi

# Get the PID of the rsync processes under the main service's process group

# The process group ID (PGID) is the same as the main PID for the service
PGID=$(ps -o pgid= -p "$MAIN_PID" | xargs)
# Find rsync children
RSYNC_PIDS=$(pgrep -g "$PGID" -f rsync)

if [[ -n "$RSYNC_PIDS" ]]; then
    CURRENT_COUNT=$(echo "$RSYNC_PIDS" | wc -l)
else
    CURRENT_COUNT=0
fi

# Generate the notification output

# Load previous state
if [ -f "$STATE_FILE" ]; then
    PREV_COUNT=$(cat "$STATE_FILE")
else
    PREV_COUNT=0
fi

# Save current state
echo "$CURRENT_COUNT" > "$STATE_FILE"

if [[ "$CURRENT_COUNT" -gt 0 ]]; then
    # TOP BAR (Active)
    echo "$ICON_SYNC $CURRENT_COUNT | color=#50fa7b"
    echo "---"
    echo "Active Transfers ($CURRENT_COUNT) | color=white"

    # DROPDOWN LIST (Real-time file names)
    for pid in $RSYNC_PIDS; do
        if [ -r "/proc/$pid/cmdline" ]; then
            # Parse filename from rsync arguments
            FILE_NAME=$(tr '\0' '\n' < "/proc/$pid/cmdline" | grep "^+ " | grep -v "^+ \*/$" | sed 's/^+ //')

            if [[ -n "$FILE_NAME" ]]; then
                # Each file is a menu item. Clicking it does nothing (action undefined), just information.
                echo "-- $FILE_NAME | iconName=text-x-generic-symbolic"
            else
                echo "-- Unknown File (PID $pid)"
            fi
        fi
    done
else
    echo "$ICON_IDLE | color=white"
    echo "---"
    echo "Status: Idle | iconName=weather-clear-symbolic"
    echo "Waiting for new files..."
fi

# Argos Menu Options
echo "---"
# Log check
if [ -r "$LOG_FILE" ]; then
    LAST_LOG=$(tail -n 1 "$LOG_FILE" | cut -c 20-50)
    echo "Log: $LAST_LOG... | color=#888888 size=9"
    echo "Open Log File | iconName=text-x-script-symbolic bash='xdg-open $LOG_FILE' terminal=false"
fi

echo "Restart Service | iconName=system-restart-symbolic bash='gnome-terminal -- bash -c \"sudo systemctl restart $SERVICE_NAME\"' terminal=false"
echo "Refresh | refresh=true"
