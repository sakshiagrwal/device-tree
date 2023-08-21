#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to display section dividers
divider() {
    local divider_char="-"
    local divider_length=80
    local divider_color="${GREEN}"
    local reset_color="${NC}"

    printf "${divider_color}"
    printf "%${divider_length}s\n" | tr ' ' "$divider_char"
    printf "${reset_color}"
}



# Function to delete a directory and show status in green color
delete_directory() {
    local directory="$1"

    if [ -d "$directory" ]; then
        rm -rf "$directory"
        echo -e "${GREEN}Directory '$directory' deleted successfully.${NC}"
    else
        echo -e "${YELLOW}Directory '$directory' does not exist. Skipping deletion.${NC}"
    fi
}

# Function to clone repositories
clone_repo() {
    local repo_url="$1"
    local branch="$2"
    local destination="$3"

    echo -e "${YELLOW}Cloning $destination...${NC}"
    git clone -b "$branch" "$repo_url" "$destination"
}

# Function to apply patches
apply_patch() {
    local directory="$1"
    local repo_url="$2"
    local branch="$3"
    local commit_hash="$4"

    echo -e "${YELLOW}Applying patches to $directory...${NC}"
    pushd "$directory"
    git fetch "$repo_url" "$branch"
    if git cherry-pick "$commit_hash"; then
        echo -e "${GREEN}Patches applied successfully to $directory.${NC}"
    else
        echo -e "${RED}Failed to apply patches to $directory.${NC}"
    fi
    popd
}

# Main script

divider

# Remove unwanted directories and show status
delete_directory "hardware/st/nfc"
delete_directory "device/qcom/common"
delete_directory "device/qcom/common-sepolicy"

divider

# Device (QCOM) repositories
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common.git" "thirteen" "device/qcom/common"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common-sepolicy.git" "thirteen" "device/qcom/common-sepolicy"

divider

# Applying patches
apply_patch "device/qcom/common" "https://github.com/parixxshit/device_qcom_common.git" "13" "feb9d85"
apply_patch "device/qcom/common-sepolicy" "https://github.com/parixxshit/device_qcom_common-sepolicy.git" "13" "1a7aa02"
