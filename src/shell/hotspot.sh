#!/bin/bash

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/phone/hotspot.conf"

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        return 1
    fi

    while IFS='=' read -r key val || [ -n "$key" ]; do
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        val=$(echo "$val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        case "$key" in
            ssid) HOTSPOT_SSID="$val" ;;
            password) HOTSPOT_PASSWORD="$val" ;;
            mode) HOTSPOT_MODE="$val" ;;
        esac
    done < "$CONFIG_FILE"
}

probe_state() {
    local dump
    dump=$(adb -d shell "su -c 'dumpsys wifi'" 2>/dev/null)

    if echo "$dump" | grep -q "StateMachine mode: StartedState"; then
        HOTSPOT_STATE="on"
    else
        HOTSPOT_STATE="off"
    fi

    HOTSPOT_SSID=$(echo "$dump" | grep "StateMachine mode: StartedState" -A 15 | grep "mCurrentSoftApConfiguration.SSID:" | head -1 | sed 's/.*SSID: //' | tr -d '\r\n ')
    HOTSPOT_CLIENTS=$(echo "$dump" | grep "StateMachine mode: StartedState" -B 5 | grep "getConnectedClientList().size():" | tail -1 | sed 's/.*size(): //' | tr -d '\r\n ')
}

validate_config() {
    local ssid="$1" password="$2" mode="$3"
    local errors=""

    if [ -z "$ssid" ]; then
        errors="${errors}ssid is required\n"
    fi

    if [ -z "$mode" ]; then
        errors="${errors}mode is required\n"
    elif [ "$mode" != "open" ] && [ "$mode" != "wpa2" ] && [ "$mode" != "wpa3" ] && [ "$mode" != "wpa3_transition" ]; then
        errors="${errors}mode must be open, wpa2, wpa3, or wpa3_transition\n"
    fi

    if [ "$mode" != "open" ]; then
        if [ -z "$password" ]; then
            errors="${errors}password is required for $mode mode\n"
        elif [ ${#password} -lt 8 ] || [ ${#password} -gt 63 ]; then
            errors="${errors}password must be 8-63 characters\n"
        fi
    fi

    if [ -n "$errors" ]; then
        echo -e "$errors" >&2
        return 1
    fi
    return 0
}

cmd_on() {
    local ssid="${HOTSPOT_SSID:-}" password="${HOTSPOT_PASSWORD:-}" mode="${HOTSPOT_MODE:-}"

    if ! validate_config "$ssid" "$password" "$mode"; then
        return 1
    fi

    probe_state
    if [ "$HOTSPOT_STATE" = "on" ]; then
        printf "Hotspot already running, turning off... "
        output=$(adb -d shell "su -c 'cmd wifi stop-softap'" 2>&1)
        if [ $? -eq 0 ]; then
            echo "done!"
        else
            echo "failed"
            printf "\n%s\n" "$output"
            return 1
        fi
    fi

    printf "Turning hotspot on... "
    if [ "$mode" = "open" ]; then
        output=$(adb -d shell "su -c 'cmd wifi start-softap \"$ssid\" open'" 2>&1)
    else
        output=$(adb -d shell "su -c 'cmd wifi start-softap \"$ssid\" $mode $password'" 2>&1)
    fi
    if [ $? -eq 0 ]; then
        echo "done!"
        echo "ssid: $ssid"
        if [ "$mode" = "open" ]; then
            echo "password: (none for open mode)"
        else
            echo "password: $password"
        fi
        echo "mode: $mode"
    else
        echo "failed"
        printf "\n%s\n" "$output"
        return 1
    fi
}

cmd_off() {
    printf "Turning hotspot off... "
    output=$(adb -d shell "su -c 'cmd wifi stop-softap'" 2>&1)
    if [ $? -eq 0 ]; then
        echo "done!"
    else
        echo "failed"
        printf "\n%s\n" "$output"
        return 1
    fi
}

cmd_status() {
    probe_state

    if [ "$HOTSPOT_STATE" != "on" ]; then
        echo "hotspot is off."
        return 0
    fi

    if [ -z "$HOTSPOT_SSID" ]; then
        echo "ssid: (unknown)"
    else
        echo "ssid: $HOTSPOT_SSID"
    fi

    if [ -n "$HOTSPOT_CLIENTS" ]; then
        echo "clients: $HOTSPOT_CLIENTS"
    else
        echo "clients: 0"
    fi
}

cmd_config() {
    local dir
    dir=$(dirname "$CONFIG_FILE")

    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" <<'EOF'
ssid=
password=
mode= # open, wpa2, wpa3, or wpa3_transition
EOF
    fi

    "${EDITOR:-nano}" "$CONFIG_FILE"
}

usage() {
    echo "Usage: hotspot.sh <on|off|status|config>"
    echo ""
    echo "Commands:"
    echo "  on      Turn hotspot on (default)"
    echo "  off     Turn hotspot off"
    echo "  status  Show hotspot status"
    echo "  config  Open config file in editor"
    echo ""
    echo "Options:"
    echo "  --ssid, -s <ssid>      Override SSID"
    echo "  --password, -p <pass>  Override password"
    echo "  --mode, -m <mode>      Override mode (open, wpa2, wpa3, wpa3_transition)"
}

HOTSPOT_SSID="" HOTSPOT_PASSWORD="" HOTSPOT_MODE=""
OVERRIDE_SSID="" OVERRIDE_PASSWORD="" OVERRIDE_MODE=""

COMMAND="on"

while [ $# -gt 0 ]; do
    case "$1" in
        on|off|status|config)
            COMMAND="$1"
            shift
            ;;
        -s|--ssid)
            OVERRIDE_SSID="$2"
            shift 2
            ;;
        -p|--password)
            OVERRIDE_PASSWORD="$2"
            shift 2
            ;;
        -m|--mode)
            OVERRIDE_MODE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ "$COMMAND" != "config" ] && [ "$COMMAND" != "off" ]; then
    if ! load_config; then
        echo "error: hotspot is not configured; run \`phone hotspot config\` to configure." >&2
        exit 1
    fi

    if [ -n "$OVERRIDE_SSID" ]; then
        HOTSPOT_SSID="$OVERRIDE_SSID"
    fi
    if [ -n "$OVERRIDE_PASSWORD" ]; then
        HOTSPOT_PASSWORD="$OVERRIDE_PASSWORD"
    fi
    if [ -n "$OVERRIDE_MODE" ]; then
        HOTSPOT_MODE="$OVERRIDE_MODE"
    fi

    if [ "$OVERRIDE_MODE" = "open" ] && [ -n "$OVERRIDE_PASSWORD" ]; then
        echo "error: cannot set password with --mode open" >&2
        exit 1
    fi
fi

case "$COMMAND" in
    on)     cmd_on ;;
    off)    cmd_off ;;
    status) cmd_status ;;
    config) cmd_config ;;
esac
