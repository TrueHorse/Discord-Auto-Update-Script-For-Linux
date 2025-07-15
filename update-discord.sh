#!/bin/bash

# Directory where Discord is installed
DISCORD_DIR="/usr/share/discord"

# URL to fetch the latest .deb package
DISCORD_DOWNLOAD_URL="https://discord.com/api/download/stable?platform=linux&format=deb"

DISCORD_VERSION_URL="https://discord.com/api/updates/stable?platform=linux"

# Temporary directory for downloading the latest package
TEMP_DIR="/tmp/discord_update"

# Function to get the current installed version
get_installed_version() {
    if [[ -f "$DISCORD_DIR/resources/build_info.json" ]]; then
        INSTALLED_VERSION=$(jq -r '.version' "$DISCORD_DIR/resources/build_info.json")
    else
        INSTALLED_VERSION="none"
    fi
}

# Function to get the latest available version
get_latest_version() {
    LATEST_VERSION=$(curl -s "$DISCORD_VERSION_URL" -L | jq -r '.name')
}

# Function to update Discord
update_discord() {
    curl -s "$DISCORD_DOWNLOAD_URL" -L -o "$TEMP_DIR/discord.deb" && pkexec dpkg -i "$TEMP_DIR/discord.deb"
    rm -rf "$TEMP_DIR"
}

# Create temp directory if it doesn't exist
mkdir -p "$TEMP_DIR"

# Get current installed version
get_installed_version

# Get latest available version
get_latest_version

# Compare versions and update if needed
if [[ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]]; then
    echo "Updating Discord from version $INSTALLED_VERSION to $LATEST_VERSION"
    # Close Discord if running
    pkill Discord
    sleep 5  # Wait a few seconds to ensure Discord is closed
    # Update Discord
    update_discord
else
    echo "Discord is already up-to-date (version $INSTALLED_VERSION)"
fi

# Launch Discord
/usr/share/discord/Discord