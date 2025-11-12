#!/bin/bash

# WebRTC Install Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Creating installation structure in: $SCRIPT_DIR"

# Create directories
mkdir -p install/include
mkdir -p install/lib

echo "Copying headers..."
# Copy all .h files preserving directory structure
find . -name "*.h" \
    -not -path "./out/*" \
    -not -path "./build/*" \
    -not -path "./.git/*" \
    -not -path "./buildtools/*" \
    -not -path "./tools/*" \
    -exec cp --parents {} install/include/ \;

echo "Copying library..."
# Copy the built library
cp out/Release/obj/libwebrtc.a install/lib/

echo ""
echo "Installation complete!"
echo "  Headers: $SCRIPT_DIR/install/include"
echo "  Library: $SCRIPT_DIR/install/lib/libwebrtc.a"
