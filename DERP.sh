#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dividers
HEAVY_S=$(printf '━%.0s' {1..100})
LIGHT_S=$(printf '─%.0s' {1..100})

# Function to delete a directory
delete_directory() {
    local directory="$1"

    if [ -d "$directory" ]; then
        rm -rf "$directory"
        echo -e "${GREEN}Directory '$directory' deleted successfully.${NC}"
    else
        echo -e "${YELLOW}Directory '$directory' does not exist. Skipping deletion.${NC}"
    fi
}

# Function to clone a repository
clone_repo() {
    local repo_url="$1"
    local branch="$2"
    local destination="$3"

    echo -e "${YELLOW}Cloning $repo_url...${NC}"

    if git clone --depth 1 -b "$branch" "$repo_url" "$destination"; then
        echo -e "${GREEN}Repository cloned successfully to $destination.${NC}\n"
    else
        echo -e "${RED}Failed to clone repository to $destination.${NC}\n"
        return 1
    fi
}

# Function to get commit name
get_commit_name() {
    local repo_url="$1"
    local commit_hash="$2"

    local commit_name=$(git log -1 --format="%s" "$commit_hash")
    echo "$commit_name"
}

# Function to apply patches
apply_patches() {
    local directory="$1"
    local repo_url="$2"
    local branch="$3"
    local commit_hashes=("${@:4}")  # Collect all commit hashes into an array

    echo -e "${YELLOW}Applying patches to $directory...${NC}"

    if pushd "$directory" > /dev/null 2>&1; then
        git fetch "$repo_url" "$branch" > /dev/null 2>&1
        for commit_hash in "${commit_hashes[@]}"; do
            commit_name=$(get_commit_name "$repo_url" "$commit_hash")
            if git cherry-pick "$commit_hash" > /dev/null 2>&1; then
                echo -e "${GREEN}Patch with commit '$commit_name' applied successfully to $directory.${NC}\n"
            else
                echo -e "${RED}Failed to apply patch with commit '$commit_name' to $directory.${NC}\n"
            fi
        done
        popd > /dev/null 2>&1
    else
        echo -e "${RED}Directory $directory does not exist. Skipping apply patch.${NC}\n"
    fi
}

# Remove repositories
echo -e "${GREEN}${HEAVY_S}${NC}"
delete_directory "hardware/st/nfc"
delete_directory "packages/apps/Dialer"
delete_directory "packages/apps/Contacts"
delete_directory "packages/apps/Messaging"
delete_directory "packages/resources/devicesettings"

# Clone repositories
echo -e "\n${GREEN}${HEAVY_S}${NC}"
clone_repo "https://github.com/sakshiagrwal/device_xiaomi_spes.git" "thirteen" "device/xiaomi/spes"
clone_repo "https://github.com/sakshiagrwal/device_xiaomi_sm6225-common.git" "thirteen" "device/xiaomi/sm6225-common"
clone_repo "https://github.com/PixelExperience-Devices/device_xiaomi_sm6225-common-miuicamera.git" "thirteen" "device/xiaomi/sm6225-common-miuicamera"
clone_repo "https://github.com/PixelExperience-Devices/kernel_xiaomi_sm6225.git" "thirteen" "kernel/xiaomi/sm6225"
clone_repo "https://github.com/PixelExperience-Devices/device_xiaomi_spes-kernel.git" "thirteen" "device/xiaomi/spes-kernel"
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_spes.git" "thirteen" "vendor/xiaomi/spes"
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_sm6225-common.git" "thirteen" "vendor/xiaomi/sm6225-common"
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi_sm6225-common-miuicamera.git" "thirteen" "vendor/xiaomi/sm6225-common-miuicamera"
clone_repo "https://github.com/P-404/android_packages_apps_Dialer.git" "tokui" "packages/apps/Dialer"
clone_repo "https://github.com/P-404/android_packages_apps_Contacts.git" "tokui" "packages/apps/Contacts"
clone_repo "https://github.com/P-404/android_packages_apps_Messaging.git" "tokui" "packages/apps/Messaging"
clone_repo "https://github.com/PixelExperience/packages_resources_devicesettings.git" "thirteen" "packages/resources/devicesettings"
clone_repo "https://github.com/PixelExperience/hardware_st_nfc.git" "thirteen" "hardware/st/nfc"
clone_repo "https://github.com/PixelExperience/hardware_xiaomi.git" "thirteen" "hardware/xiaomi"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_gps.git" "thirteen" "hardware/qcom-caf/bengal/gps"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_media.git" "thirteen" "hardware/qcom-caf/bengal/media"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_audio.git" "thirteen" "hardware/qcom-caf/bengal/audio"
clone_repo "https://github.com/PixelExperience/hardware_qcom-caf_bengal_display.git" "thirteen" "hardware/qcom-caf/bengal/display"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common.git" "thirteen" "device/qcom/common"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_qssi.git" "thirteen" "device/qcom/qssi"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_wlan.git" "thirteen" "device/qcom/wlan"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_common-sepolicy.git" "thirteen" "device/qcom/common-sepolicy"
clone_repo "https://github.com/PixelExperience-Devices/device_qcom_vendor-common.git" "thirteen" "device/qcom/vendor-common"
clone_repo "https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_qcom_common.git" "thirteen" "vendor/qcom/common"
clone_repo "https://github.com/PixelExperience/vendor_qcom_opensource_core-utils.git" "thirteen" "vendor/qcom/opensource/core-utils"
clone_repo "https://github.com/PixelExperience/vendor_qcom_opensource_commonsys_dpm.git" "thirteen" "vendor/qcom/opensource/commonsys/dpm"
clone_repo "https://github.com/PixelExperience/vendor_qcom_opensource_commonsys-intf_bluetooth.git" "thirteen" "vendor/qcom/opensource/commonsys-intf/bluetooth"

# Applying patches
echo -e "\n${GREEN}${HEAVY_S}${NC}"
apply_patches "frameworks/base" "https://github.com/parixxshit/frameworks_base.git" "13" "8b318b0" "50ab912"
apply_patches "vendor/pixel-framework" "https://github.com/parixxshit/vendor_pixel-framework.git" "13" "cbafd53"
apply_patches "device/qcom/common" "https://github.com/parixxshit/device_qcom_common.git" "13" "feb9d85" "7909a81"
apply_patches "device/qcom/common-sepolicy" "https://github.com/parixxshit/device_qcom_common-sepolicy.git" "13" "e4c9045"
apply_patches "packages/apps/Settings" "https://github.com/parixxshit/packages_apps_Settings.git" "13" "0631144" "be06b4e"
apply_patches "vendor/derp" "https://github.com/parixxshit/vendor_derp.git" "13" "01370e0" "33d01f6"
apply_patches "vendor/qcom/opensource/fm-commonsys" "https://github.com/PixelExperience/vendor_qcom_opensource_fm-commonsys.git" "13" "74f4211"
