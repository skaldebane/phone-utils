#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

help() {
    echo "Usage: phone <command>"
    echo ""
    echo "Commands:"
    echo "  refresh   Force network re-registration via 2G->LTE"
    echo "  tether    Enable USB RNDIS tethering"
    echo "  untether  Disable tethering, set USB to MTP"
}

case "$1" in
    refresh)
        "$SCRIPT_DIR/phone-refresh.sh"
        ;;
    tether)
        adb -d shell svc usb setFunctions rndis
        ;;
    untether)
        adb -d shell svc usb setFunctions mtp
        ;;
    *)
        help
        ;;
esac
