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



# Function to delete a directory and show status
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
delete_directory "packages/apps/Dialer"
delete_directory "packages/apps/Contacts"
delete_directory "packages/apps/Messaging"
delete_directory "packages/resources/devicesettings"

divider

# Device repositories
git clone -b thirteen https://github.com/sakshiagrwal/device_xiaomi_spes.git device/xiaomi/spes
git clone -b thirteen https://github.com/sakshiagrwal/device_xiaomi_sm6225-common.git device/xiaomi/sm6225-common
git clone -b thirteen https://github.com/PixelExperience-Devices/device_xiaomi_sm6225-common-miuicamera.git device/xiaomi/sm6225-common-miuicamera

git clone -b thirteen https://github.com/PixelExperience-Devices/kernel_xiaomi_sm6225.git kernel/xiaomi/sm6225
git clone -b thirteen https://github.com/PixelExperience-Devices/device_xiaomi_spes-kernel.git device/xiaomi/spes-kernel

git clone -b thirteen https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_spes.git vendor/xiaomi/spes
git clone -b thirteen https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_sm6225-common.git vendor/xiaomi/sm6225-common
git clone -b thirteen https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_sm6225-common-miuicamera.git vendor/xiaomi/sm6225-common-miuicamera

# Packages repositories
git clone -b tokui https://github.com/P-404/android_packages_apps_Dialer.git packages/apps/Dialer
git clone -b tokui https://github.com/P-404/android_packages_apps_Contacts.git packages/apps/Contacts
git clone -b tokui https://github.com/P-404/android_packages_apps_Messaging.git packages/apps/Messaging
git clone -b thirteen https://github.com/PixelExperience/packages_resources_devicesettings.git packages/resources/devicesettings

# Hardware repositories
git clone -b thirteen https://github.com/PixelExperience/hardware_st_nfc.git hardware/st/nfc
git clone -b thirteen https://github.com/PixelExperience/hardware_xiaomi.git hardware/xiaomi

git clone -b thirteen https://github.com/PixelExperience/hardware_qcom-caf_bengal_gps.git hardware/qcom-caf/bengal/gps
git clone -b thirteen https://github.com/PixelExperience/hardware_qcom-caf_bengal_media.git hardware/qcom-caf/bengal/media
git clone -b thirteen https://github.com/PixelExperience/hardware_qcom-caf_bengal_audio.git hardware/qcom-caf/bengal/audio
git clone -b thirteen https://github.com/PixelExperience/hardware_qcom-caf_bengal_display.git hardware/qcom-caf/bengal/display

# Device (QCOM) repositories
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common.git" "thirteen" "device/qcom/common"
git clone -b thirteen https://github.com/PixelExperience-Devices/device_qcom_qssi.git device/qcom/qssi
git clone -b thirteen https://github.com/PixelExperience-Devices/device_qcom_wlan.git device/qcom/wlan
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common-sepolicy.git" "thirteen" "device/qcom/common-sepolicy"
git clone -b thirteen https://github.com/PixelExperience-Devices/device_qcom_vendor-common.git device/qcom/vendor-common

# Vendor (QCOM) repositories
git clone -b thirteen https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_qcom_common.git vendor/qcom/common
git clone -b thirteen https://github.com/PixelExperience/vendor_qcom_opensource_core-utils.git vendor/qcom/opensource/core-utils
git clone -b thirteen https://github.com/PixelExperience/vendor_qcom_opensource_commonsys_dpm.git vendor/qcom/opensource/commonsys/dpm
git clone -b thirteen https://github.com/PixelExperience/vendor_qcom_opensource_commonsys-intf_bluetooth.git vendor/qcom/opensource/commonsys-intf/bluetooth

divider

# Applying patches
apply_patch "device/qcom/common" "https://github.com/parixxshit/device_qcom_common.git" "13" "feb9d85"
apply_patch "device/qcom/common-sepolicy" "https://github.com/parixxshit/device_qcom_common-sepolicy.git" "13" "1a7aa02"
