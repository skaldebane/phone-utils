#!/bin/bash

set_usb_function() {
    local target=$1
    local label=$2
    local max_attempts=8
    local state_output
    local output
    local functions
    local state

    state_output=$(adb -d get-state 2>&1)
    if [ $? -ne 0 ]; then
        printf "Switching USB to %s... failed\n" "$label"
        printf "\n%s\n" "$state_output"
        return 1
    fi

    printf "Switching USB to %s... " "$label"
    output=$(adb -d shell svc usb setFunctions "$target" 2>&1)
    if [ $? -eq 0 ]; then
        echo "done"
        return 0
    fi

    for _ in $(seq 1 $max_attempts); do
        functions=$(adb -d shell svc usb getFunctions 2>/dev/null | tr -d '\r\n')
        if [ -n "$functions" ] && [[ ",$functions," == *",$target,"* ]]; then
            echo "done"
            return 0
        fi
        state=$(adb -d get-state 2>/dev/null | tr -d '\r\n')
        if [ -z "$output" ] && [ "$state" = "device" ]; then
            echo "done"
            return 0
        fi
        sleep 1
    done

    if [ -z "$output" ]; then
        echo "done"
        return 0
    fi

    echo "failed"
    printf "\n%s\n" "$output"
    return 1
}

case "$1" in
    tether)
        set_usb_function rndis RNDIS
        ;;
    mtp)
        set_usb_function mtp MTP
        ;;
    *)
        echo "Usage: usb.sh <tether|mtp>"
        ;;
esac
