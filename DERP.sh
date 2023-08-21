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
clone_repo "https://github.com/sakshiagrwal/device_xiaomi_spes.git" "thirteen" "device/xiaomi/spes"
clone_repo "https://github.com/sakshiagrwal/device_xiaomi_sm6225-common.git" "thirteen" "device/xiaomi/sm6225-common"
clone_repo "https://github.com/PixelExperience-Devices/device_xiaomi_sm6225-common-miuicamera.git" "thirteen" "device/xiaomi/sm6225-common-miuicamera"

clone_repo "https://github.com/PixelExperience-Devices/kernel_xiaomi_sm6225.git" "thirteen" "kernel/xiaomi/sm6225"
clone_repo "https://github.com/PixelExperience-Devices/device_xiaomi_spes-kernel.git" "thirteen" "device/xiaomi/spes-kernel"

clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_spes.git" "thirteen" "vendor/xiaomi/spes"
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_sm6225-common.git" "thirteen" "vendor/xiaomi/sm6225-common"
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_sm6225-common-miuicamera.git" "thirteen" "vendor/xiaomi/sm6225-common-miuicamera"

# Packages repositories
git clone -b tokui https://github.com/P-404/android_packages_apps_Dialer.git" "tokui" "packages/apps/Dialer"
git clone -b tokui https://github.com/P-404/android_packages_apps_Contacts.git" "tokui" "packages/apps/Contacts"
git clone -b tokui https://github.com/P-404/android_packages_apps_Messaging.git" "tokui" "packages/apps/Messaging"
git clone -b thirteen https://github.com/PixelExperience/packages_resources_devicesettings.git" "thirteen" "packages/resources/devicesettings"

# Hardware repositories
clone_repo "https://github.com/PixelExperience/hardware_st_nfc.git" "thirteen" "hardware/st/nfc"
clone_repo "https://github.com/PixelExperience/hardware_xiaomi.git" "thirteen" "hardware/xiaomi"

clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_gps.git " "thirteen" "hardware/qcom-caf/bengal/gps"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_media.git" "thirteen" "hardware/qcom-caf/bengal/media"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_audio.git" "thirteen" "hardware/qcom-caf/bengal/audio"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_display.git" "thirteen" "hardware/qcom-caf/bengal/display"

# Device (QCOM) repositories
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common.git" "thirteen" "device/qcom/common"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_qssi.git" "thirteen" "device/qcom/qssi"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_wlan.git" "thirteen" "device/qcom/wlan"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common-sepolicy.git" "thirteen" "device/qcom/common-sepolicy"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_vendor-common.git" "thirteen" "device/qcom/vendor-common"

# Vendor (QCOM) repositories
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_qcom_common.git" "thirteen" "vendor/qcom/common"
clone_repo "https://github.com/PixelExperience/vendor_qcom_opensource_core-utils.git" "thirteen" "vendor/qcom/opensource/core-utils"
clone_repo "https://github.com/PixelExperience/vendor_qcom_opensource_commonsys_dpm.git" "thirteen" "vendor/qcom/opensource/commonsys/dpm"
clone_repo "https://github.com/PixelExperience/vendor_qcom_opensource_commonsys-intf_bluetooth.git" "thirteen" "vendor/qcom/opensource/commonsys-intf/bluetooth"

divider

# Applying patches
apply_patch "device/qcom/common" "https://github.com/parixxshit/device_qcom_common.git" "13" "feb9d85"
apply_patch "device/qcom/common-sepolicy" "https://github.com/parixxshit/device_qcom_common-sepolicy.git" "13" "1a7aa02"
