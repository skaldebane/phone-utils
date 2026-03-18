#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

printf "Pushing DEX... "
adb push "$SCRIPT_DIR/src/out/classes.dex" /data/local/tmp/SetNetworkModePoll.dex > /dev/null 2>&1
echo "done"

SUBID=4

wait_for_data_rat() {
    local rat=$1
    local name=$2
    local max_attempts=30
    
    printf "Waiting for $name data... "
    for i in $(seq 1 $max_attempts); do
        local state=$(adb shell su -c "dumpsys telephony.registry 2>/dev/null | grep 'subId=$SUBID phoneId=' | grep 'mVoiceRegState=0' | tail -1")
        if echo "$state" | grep -E "MobileDataRat=$rat" > /dev/null; then
            echo "connected!"
            return 0
        fi
        sleep 1
    done
    echo "timeout"
    return 1
}

echo "Setting 2G only..."
adb shell "su -c 'CLASSPATH=/data/local/tmp/SetNetworkModePoll.dex app_process / SetNetworkModePoll $SUBID 1'" > /dev/null 2>&1

wait_for_data_rat "EDGE|GSM" "2G"

echo "Setting 4G/3G/2G auto..."
adb shell "su -c 'CLASSPATH=/data/local/tmp/SetNetworkModePoll.dex app_process / SetNetworkModePoll $SUBID 524287'" > /dev/null 2>&1

wait_for_data_rat "LTE" "LTE"

echo "Refresh complete!"
