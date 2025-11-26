#!/bin/bash

# Arduino LED Patterns Upload Script
# This script installs Arduino CLI if needed and uploads the sketch

set -e  # Exit on error

SKETCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARDUINO_CLI_VERSION="0.35.3"

echo "=== Arduino LED Patterns Upload Script ==="
echo ""

# Check if arduino-cli is installed
if ! command -v arduino-cli &> /dev/null; then
    echo "Arduino CLI not found. Installing..."
    
    # Detect OS and architecture
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$ARCH" in
        x86_64)
            ARCH="64bit"
            ;;
        aarch64|arm64)
            ARCH="ARM64"
            ;;
        armv7l)
            ARCH="ARMv7"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # Download Arduino CLI
    DOWNLOAD_URL="https://github.com/arduino/arduino-cli/releases/download/${ARDUINO_CLI_VERSION}/arduino-cli_${ARDUINO_CLI_VERSION}_${OS^}_${ARCH}.tar.gz"
    
    echo "Downloading Arduino CLI from: $DOWNLOAD_URL"
    curl -fsSL "$DOWNLOAD_URL" -o /tmp/arduino-cli.tar.gz
    
    # Extract and install
    sudo tar -xzf /tmp/arduino-cli.tar.gz -C /usr/local/bin arduino-cli
    sudo chmod +x /usr/local/bin/arduino-cli
    rm /tmp/arduino-cli.tar.gz
    
    echo "Arduino CLI installed successfully!"
    echo ""
fi

# Verify arduino-cli is working
arduino-cli version

# Check if Arduino core is installed
echo ""
echo "Checking for Arduino AVR core..."
if ! arduino-cli core list | grep -q "arduino:avr"; then
    echo "Installing Arduino AVR core..."
    arduino-cli core update-index
    arduino-cli core install arduino:avr
    echo "Arduino AVR core installed!"
else
    echo "Arduino AVR core already installed."
fi

echo ""
echo "=== Detecting Arduino Board ==="
arduino-cli board list

# Try to auto-detect the board
BOARD_PORT=$(arduino-cli board list | grep -E "tty(USB|ACM)" | awk '{print $1}' | head -n 1)

if [ -z "$BOARD_PORT" ]; then
    echo ""
    echo "ERROR: No Arduino board detected!"
    echo "Please:"
    echo "  1. Connect your Arduino via USB"
    echo "  2. Make sure the USB cable supports data (not just power)"
    echo "  3. Run this script again"
    exit 1
fi

echo ""
echo "Found Arduino on port: $BOARD_PORT"
echo ""

# Compile the sketch
echo "=== Compiling Sketch ==="
arduino-cli compile --fqbn arduino:avr:uno "$SKETCH_DIR"

echo ""
echo "=== Uploading to Arduino ==="
arduino-cli upload -p "$BOARD_PORT" --fqbn arduino:avr:uno "$SKETCH_DIR"

echo ""
echo "=== Upload Complete! ==="
echo ""
echo "Your Arduino is now running the LED patterns sketch!"
echo "Use the button on pin 10 to cycle through 5 different modes:"
echo "  - Mode 0: Knight Rider (back and forth)"
echo "  - Mode 1: Chase Light (accumulating)"
echo "  - Mode 2: Blink All LEDs (Christmas-style)"
echo "  - Mode 3: Binary Counter"
echo "  - Mode 4: Odd-Even Alternating"
echo ""
echo "Hardware setup:"
echo "  - LEDs on pins 2-9 (with resistors to GND)"
echo "  - Button on pin 10 (to GND, using INPUT_PULLUP)"
