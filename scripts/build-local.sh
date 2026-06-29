#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZMK_DIR="${ZMK_DIR:-$ROOT_DIR/.zmk-local}"
DOCKER_IMAGE="${DOCKER_IMAGE:-zmkfirmware/zmk-build-arm:stable}"
BOARD="${BOARD:-nice_nano}"
SHIELD="${SHIELD:-zmk_controller_pad}"
BUILD_DIR="${BUILD_DIR:-/workspaces/zmk/build/$SHIELD}"
OUTPUT_DIR="$ROOT_DIR/firmware"
OUTPUT_FILE="$OUTPUT_DIR/${SHIELD}.uf2"

command -v docker >/dev/null 2>&1 || {
    echo "Error: Docker is not installed or is not in PATH." >&2
    exit 1
}

mkdir -p "$OUTPUT_DIR"

if [ ! -d "$ZMK_DIR/.git" ]; then
    echo "Cloning ZMK into $ZMK_DIR..."
    git clone --depth 1 https://github.com/zmkfirmware/zmk.git "$ZMK_DIR"
fi

echo "Pulling Docker image $DOCKER_IMAGE..."
docker pull "$DOCKER_IMAGE"

if [ ! -d "$ZMK_DIR/.west" ]; then
    echo "Initializing west workspace..."
    docker run --rm \
        -v "$ZMK_DIR:/workspaces/zmk" \
        -w /workspaces/zmk \
        "$DOCKER_IMAGE" \
        west init -l app
fi

echo "Updating west dependencies..."
docker run --rm \
    -v "$ZMK_DIR:/workspaces/zmk" \
    -w /workspaces/zmk \
    "$DOCKER_IMAGE" \
    west update

echo "Building $BOARD + $SHIELD..."
docker run --rm \
    -v "$ZMK_DIR:/workspaces/zmk" \
    -v "$ROOT_DIR:/workspaces/config" \
    -w /workspaces/zmk \
    "$DOCKER_IMAGE" \
    west build \
        -s app \
        -d "$BUILD_DIR" \
        -p always \
        -b "$BOARD" \
        -- \
        -DSHIELD="$SHIELD" \
        -DZMK_CONFIG=/workspaces/config/config \
        -DZMK_EXTRA_MODULES=/workspaces/config

cp "$ZMK_DIR/build/$SHIELD/zephyr/zmk.uf2" "$OUTPUT_FILE"
xattr -c "$OUTPUT_FILE" 2>/dev/null || true

echo "Firmware generated: $OUTPUT_FILE"
