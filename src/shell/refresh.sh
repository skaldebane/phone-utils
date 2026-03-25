#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
DEX="$SCRIPT_DIR/classes.dex"

printf "Pushing DEX... "
push_output=$(adb push "$DEX" /data/local/tmp/SetNetworkModePoll.dex 2>&1)
if [ $? -eq 0 ]; then
    echo "done"
else
    echo "failed"
    printf "\n%s\n" "$push_output"
    exit 1
fi

get_active_data_subid() {
    local active
    active=$(adb shell su -c "dumpsys telephony.registry 2>/dev/null | grep -m1 'mActiveDataSubId=' | sed -E 's/.*mActiveDataSubId=([-0-9]+).*/\1/'" 2>/dev/null | tr -d '\r')
    if [[ "$active" =~ ^[0-9]+$ ]]; then
        echo "$active"
        return 0
    fi
    return 1
}

get_default_data_subid() {
    local subid
    subid=$(adb shell su -c "cmd phone get-default-data-subscription-id 2>/dev/null" 2>/dev/null | tr -d '\r')
    if [[ "$subid" =~ ^[0-9]+$ ]]; then
        echo "$subid"
        return 0
    fi
    return 1
}

is_mobile_data_enabled() {
    local enabled
    enabled=$(adb shell su -c "settings get global mobile_data 2>/dev/null" 2>/dev/null | tr -d '\r')
    [ "$enabled" = "1" ]
}

wait_for_data_rat() {
    local rat=$1
    local name=$2
    local max_attempts=30

    printf "Waiting for $name data... "
    for i in $(seq 1 $max_attempts); do
        local state
        state=$(adb shell su -c "dumpsys telephony.registry 2>/dev/null | grep 'subId=$SUBID phoneId=' | grep 'mVoiceRegState=0' | tail -1")
        if echo "$state" | grep -E "MobileDataRat=$rat" > /dev/null; then
            echo "connected!"
            return 0
        fi
        sleep 1
    done
    echo "timeout"
    return 1
}

SUBID=""
if is_mobile_data_enabled; then
    SUBID=$(get_active_data_subid || true)
    if [ -z "$SUBID" ]; then
        SUBID=$(get_default_data_subid || true)
    fi
fi

if [ -z "$SUBID" ]; then
    echo "No active mobile data subscription, skipping refresh."
    exit 0
fi

echo "Setting 2G only..."
adb shell "su -c 'CLASSPATH=/data/local/tmp/SetNetworkModePoll.dex app_process / SetNetworkModePoll $SUBID 1'" > /dev/null 2>&1

wait_for_data_rat "EDGE|GSM" "2G"

echo "Setting 4G/3G/2G auto..."
adb shell "su -c 'CLASSPATH=/data/local/tmp/SetNetworkModePoll.dex app_process / SetNetworkModePoll $SUBID 524287'" > /dev/null 2>&1

wait_for_data_rat "LTE" "LTE"

echo "Refresh complete!"
