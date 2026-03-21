#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

help() {
    echo "Usage: phone <command>"
    echo ""
    echo "Commands:"
    echo "  refresh   Force network re-registration via 2G->LTE"
    echo "  tether    Enable USB RNDIS tethering"
    echo "  mtp       Disable tethering, set USB to MTP"
}

case "$1" in
    refresh)
        "$SCRIPT_DIR/refresh.sh"
        ;;
    tether|mtp)
        "$SCRIPT_DIR/usb.sh" "$1"
        ;;
    *)
        help
        ;;
esac
