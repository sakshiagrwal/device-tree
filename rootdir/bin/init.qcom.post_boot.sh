#! /vendor/bin/sh

# Copyright (c) 2012-2013, 2016-2020, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

function enable_swap() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    SWAP_ENABLE_THRESHOLD=1048576
    swap_enable=`getprop ro.vendor.qti.config.swap`

    # Enable swap initially only for 1 GB targets
    if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
        # Static swiftness
        echo 1 > /proc/sys/vm/swap_ratio_enable
        echo 70 > /proc/sys/vm/swap_ratio

        # Swap disk - 200MB size
        if [ ! -f /data/vendor/swap/swapfile ]; then
            dd if=/dev/zero of=/data/vendor/swap/swapfile bs=1m count=200
        fi
        mkswap /data/vendor/swap/swapfile
        swapon /data/vendor/swap/swapfile -p 32758
    fi
}

# Apply Settings for bengal
# fix ECC Crash
echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-gdhs/idle_enabled
echo N > /sys/module/lpm_levels/system/perf/perf-l2-gdhs/idle_enabled
echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-gdhs/suspend_enabled
echo N > /sys/module/lpm_levels/system/perf/perf-l2-gdhs/suspend_enabled

if [ -f /sys/devices/soc0/soc_id ]; then
    soc_id=`cat /sys/devices/soc0/soc_id`
else
    soc_id=`cat /sys/devices/system/soc/soc0/id`
fi

case "$soc_id" in
          "417" | "420" | "444" | "445" | "469" | "470" )

    # Core control is temporarily disabled till bring up
    echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable
    echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    # Core control parameters on big
    echo 40 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
    echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

    # Setting b.L scheduler parameters
    echo 67 > /proc/sys/kernel/sched_downmigrate
    echo 77 > /proc/sys/kernel/sched_upmigrate
    echo 85 > /proc/sys/kernel/sched_group_downmigrate
    echo 100 > /proc/sys/kernel/sched_group_upmigrate
    echo 1 > /proc/sys/kernel/sched_walt_rotate_big_tasks

    # cpuset settings
    echo 0-3 > /dev/cpuset/background/cpus
    echo 0-3 > /dev/cpuset/system-background/cpus

    # configure governor settings for little cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

    # configure governor settings for big cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

    # sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
    echo -6 >  /sys/devices/system/cpu/cpu0/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu1/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu2/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu3/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu4/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu5/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu6/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu7/sched_load_boost

    # Enable bus-dcvs
    ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
    ddr_type4="07"
    ddr_type3="05"

    for device in /sys/devices/platform/soc
    do
        for cpubw in $device/*cpu-cpu-ddr-bw/devfreq/*cpu-cpu-ddr-bw
            do
            echo "bw_hwmon" > $cpubw/governor
            echo 50 > $cpubw/polling_interval
            echo 762 > $cpubw/min_freq
            if [ ${ddr_type:4:2} == $ddr_type4 ]; then
                # LPDDR4
                echo "2288 3440 4173 5195 5859 7759 10322 11863 13763" > $cpubw/bw_hwmon/mbps_zones
                echo 85 > $cpubw/bw_hwmon/io_percent
            fi
            if [ ${ddr_type:4:2} == $ddr_type3 ]; then
                # LPDDR3
                echo "1525 3440 5195 5859 7102" > $cpubw/bw_hwmon/mbps_zones
                echo 34 > $cpubw/bw_hwmon/io_percent
            fi
            echo 4 > $cpubw/bw_hwmon/sample_ms
            echo 90 > $cpubw/bw_hwmon/decay_rate
            echo 190 > $cpubw/bw_hwmon/bw_step
            echo 20 > $cpubw/bw_hwmon/hist_memory
            echo 0 > $cpubw/bw_hwmon/hyst_length
            echo 80 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 250 > $cpubw/bw_hwmon/up_scale
            echo 1600 > $cpubw/bw_hwmon/idle_mbps
        done

    done
    # memlat specific settings are moved to seperate file under
    # device/target specific folder
    for device in /sys/devices/platform/soc
    do
        for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
        do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 400 > $memlat/mem_latency/ratio_ceil
        done

        for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
        do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
        done
    done

    # colcoation v3 disabled
    echo 0 > /proc/sys/kernel/sched_min_task_util_for_boost
    echo 0 > /proc/sys/kernel/sched_min_task_util_for_colocation

    # Turn off scheduler boost at the end
    echo 0 > /proc/sys/kernel/sched_boost

    # Turn on sleep modes
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
    ;;
esac

setprop vendor.post_boot.parsed 1

# power/perf tunings for khaje
case "$soc_id" in
          "518" )

    # Core control parameters on big
    echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable
    echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
    echo 40 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
    echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
    echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
    echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

    # Setting b.L scheduler parameters
    echo 65 > /proc/sys/kernel/sched_downmigrate
    echo 71 > /proc/sys/kernel/sched_upmigrate
    echo 85 > /proc/sys/kernel/sched_group_downmigrate
    echo 100 > /proc/sys/kernel/sched_group_upmigrate
    echo 1 > /proc/sys/kernel/sched_walt_rotate_big_tasks

    # configure governor settings for little cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/rtg_boost_freq

    # configure governor settings for big cluster
    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/rtg_boost_freq

    echo "0:1190000" > /sys/devices/system/cpu/cpu_boost/input_boost_freq
    echo 120 > /sys/devices/system/cpu/cpu_boost/input_boost_ms
    echo "0:1516800 1:0 2:0 3:0 4:1766400 5:0 6:0 7:0" > /sys/devices/system/cpu/cpu_boost/powerkey_input_boost_freq
    echo 400 > /sys/devices/system/cpu/cpu_boost/powerkey_input_boost_ms

    # sched_load_boost as -6 is equivalent to target load as 85. It is per cpu tunable.
    echo -6 >  /sys/devices/system/cpu/cpu0/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu1/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu2/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu3/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu4/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu5/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu6/sched_load_boost
    echo -6 >  /sys/devices/system/cpu/cpu7/sched_load_boost
    echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_load
    echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/hispeed_load

    # Enable bus-dcvs
    for device in /sys/devices/platform/soc
    do
        for cpubw in $device/*cpu-cpu-ddr-bw/devfreq/*cpu-cpu-ddr-bw
            do
            echo "bw_hwmon" > $cpubw/governor
            echo 50 > $cpubw/polling_interval
            echo 762 > $cpubw/min_freq
            echo "2288 3440 4173 5195 5859 7759 10322 11863 13763 15960" > $cpubw/bw_hwmon/mbps_zones
            echo 85 > $cpubw/bw_hwmon/io_percent
            echo 4 > $cpubw/bw_hwmon/sample_ms
            echo 90 > $cpubw/bw_hwmon/decay_rate
            echo 190 > $cpubw/bw_hwmon/bw_step
            echo 20 > $cpubw/bw_hwmon/hist_memory
            echo 0 > $cpubw/bw_hwmon/hyst_length
            echo 80 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 250 > $cpubw/bw_hwmon/up_scale
            echo 1600 > $cpubw/bw_hwmon/idle_mbps
        done

    done
    # memlat specific settings are moved to seperate file under
    # device/target specific folder
    for device in /sys/devices/platform/soc
    do
        for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
        do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 400 > $memlat/mem_latency/ratio_ceil
        done

        for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
        do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
        done
    done

    # colcoation v3 disabled
    echo 0 > /proc/sys/kernel/sched_min_task_util_for_boost
    echo 0 > /proc/sys/kernel/sched_min_task_util_for_colocation

    # Turn off scheduler boost at the end
    echo 0 > /proc/sys/kernel/sched_boost

    # Turn on sleep modes
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
    ;;
esac

setprop vendor.post_boot.parsed 1

# Scuba perf/power tunings
case "$soc_id" in
          "441" | "471" | "473" | "474" )
    # Quad-core device. disable core_ctl
    echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable

    # Configure schedutil governor settings
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 1305600 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_freq
    echo 614400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/rtg_boost_freq

    # sched_load_boost as -6 is equivalent to target load as 85.
    echo 0 > /proc/sys/kernel/sched_boost
    echo -6 > /sys/devices/system/cpu/cpu0/sched_load_boost
    echo -6 > /sys/devices/system/cpu/cpu1/sched_load_boost
    echo -6 > /sys/devices/system/cpu/cpu2/sched_load_boost
    echo -6 > /sys/devices/system/cpu/cpu3/sched_load_boost
    echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/hispeed_load

    # Enable bus-dcvs
    ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
    ddr_type4="07"
    ddr_type3="05"
    for device in /sys/devices/platform/soc
    do
        for cpubw in $device/*cpu-cpu-ddr-bw/devfreq/*cpu-cpu-ddr-bw
            do
            echo "bw_hwmon" > $cpubw/governor
            echo 50 > $cpubw/polling_interval
            echo 762 > $cpubw/min_freq
            if [ ${ddr_type:4:2} == $ddr_type4 ]; then
               # LPDDR4
               echo "2288 3440 4173 5195 5859 7759 10322 11863 13763" > $cpubw/bw_hwmon/mbps_zones
               echo 85 > $cpubw/bw_hwmon/io_percent
            fi
            if [ ${ddr_type:4:2} == $ddr_type3 ]; then
               # LPDDR3
               echo "1525 3440 5195 5859 7102" > $cpubw/bw_hwmon/mbps_zones
               echo 34 > $cpubw/bw_hwmon/io_percent
            fi
            echo 4 > $cpubw/bw_hwmon/sample_ms
            echo 90 > $cpubw/bw_hwmon/decay_rate
            echo 190 > $cpubw/bw_hwmon/bw_step
            echo 20 > $cpubw/bw_hwmon/hist_memory
            echo 0 > $cpubw/bw_hwmon/hyst_length
            echo 80 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 250 > $cpubw/bw_hwmon/up_scale
            echo 1600 > $cpubw/bw_hwmon/idle_mbps
        done

    done
    # memlat specific settings are moved to seperate file under
    # device/target specific folder
    for device in /sys/devices/platform/soc
    do
        for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
        do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 400 > $memlat/mem_latency/ratio_ceil
        done

        for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
        do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
        done
    done

    # Disable low power modes. Enable it after LPM stable
    echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
    ;;
esac

setprop vendor.post_boot.parsed 1
