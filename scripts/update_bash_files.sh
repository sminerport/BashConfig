#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Function to copy files in WSL environment
copy_files_wsl() {
    local CONFIG_DIR="$1"
    local WSL_DEST="$2"
    cp "$CONFIG_DIR/wsl/.bash_profile_wsl" "$WSL_DEST/.bash_profile"
    cp "$CONFIG_DIR/wsl/.bashrc_wsl" "$WSL_DEST/.bashrc"
}

# Function to copy files in Windows environment
copy_files_windows() {
    local CONFIG_DIR="$1"
    local WIN_DEST="$2"
    cp "$CONFIG_DIR/windows/.bash_profile_win" "$WIN_DEST/.bash_profile"
    cp "$CONFIG_DIR/windows/.bashrc_win" "$WIN_DEST/.bashrc"
}

# Detect if running in WSL or Windows
if grep -qi microsoft /proc/version; then
    # WSL environment
    WIN_USERNAME=$(powershell.exe -Command '[System.Environment]::UserName' | tr -d '\r' | tr -d '\0')

    # If username is not found, prompt the user to enter it
    if [ -z "$WIN_USERNAME" ]; then
        read -p "Enter your Windows username: " WIN_USERNAME
    fi

    WIN_DEST="/mnt/c/Users/$WIN_USERNAME"
    WSL_DEST="$HOME"

    # Copy files for both WSL and Windows environments
    copy_files_wsl "$SCRIPT_DIR/../config" "$WSL_DEST"
    copy_files_windows "$SCRIPT_DIR/../config" "$WIN_DEST"
    echo "Bash profile and Bashrc files have been updated in both WSL and Windows home directories."

elif uname | grep -qi 'mingw'; then
    # Windows environment with Git Bash or MinGW

    # Detect the WSL distribution and username
    WSL_DISTRO=$(wsl.exe -l -q | head -n 1 | tr -d '\r' | tr -d '\0')
    WSL_USERNAME=$(wsl.exe bash -c "whoami" | tr -d '\r' | tr -d '\0')

    # If username is not found, prompt the user to enter it
    if [ -z "$WSL_USERNAME" ]; then
        read -p "Enter your WSL username: " WSL_USERNAME
    fi

    WSL_DEST="\\\\wsl.localhost\\$WSL_DISTRO\\home\\$WSL_USERNAME"
    WIN_USERNAME=$(powershell.exe -Command '[System.Environment]::UserName' | tr -d '\r' | tr -d '\0')

    if [ -z "$WIN_USERNAME" ]; then
        read -p "Enter your Windows username: " WIN_USERNAME
    fi

    WIN_DEST="C:\\Users\\$WIN_USERNAME"

    # Copy files for both WSL and Windows environments
    copy_files_windows "$SCRIPT_DIR/../config" "$WIN_DEST"

    # Copy files to WSL from Windows using cp command
    cp "$SCRIPT_DIR/../config/wsl/.bash_profile_wsl" "$WSL_DEST/.bash_profile"
    cp "$SCRIPT_DIR/../config/wsl/.bashrc_wsl" "$WSL_DEST/.bashrc"
    echo "Bash profile and Bashrc files have been updated in both Windows and WSL home directories."

else
    echo "Unknown environment. No files copied."
fi
