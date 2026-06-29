#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHIELD="${SHIELD:-zmk_controller_pad}"
FIRMWARE="${FIRMWARE:-$ROOT_DIR/firmware/${SHIELD}.uf2}"
VOLUME="${VOLUME:-}"

if [ ! -f "$FIRMWARE" ]; then
    echo "Error: $FIRMWARE does not exist. Run ./scripts/build-local.sh first." >&2
    exit 1
fi

if [ -z "$VOLUME" ]; then
    for candidate in /Volumes/NICENANO /Volumes/NRF52BOOT; do
        if [ -d "$candidate" ]; then
            VOLUME="$candidate"
            break
        fi
    done
fi

if [ -z "$VOLUME" ] || [ ! -d "$VOLUME" ]; then
    echo "Bootloader volume not found." >&2
    echo "Connect the board over USB and double-tap reset until NICENANO or NRF52BOOT appears." >&2
    exit 1
fi

echo "Copying $FIRMWARE to $VOLUME..."
cp -X "$FIRMWARE" "$VOLUME/${SHIELD}.uf2"
sync

echo "Firmware copied. The board should reboot automatically."
