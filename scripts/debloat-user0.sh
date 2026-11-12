#!/usr/bin/env bash
# Debloat pure telemetry, log catchers, and secret trackers on Xiaomi/HyperOS for User 0.

set -euo pipefail

echo "========================================================"
echo "    Xiaomi / HyperOS User 0 Debloat & Privacy Hardening "
echo "========================================================"

DEVICE=$(adb get-serialno 2>/dev/null || true)
if [ -z "$DEVICE" ] || [ "$DEVICE" = "unknown" ]; then
    echo "[-] Error: No ADB device connected."
    exit 1
fi
echo "[+] Target Device: $DEVICE"

# List of pure telemetry and log-collecting packages safe to remove for User 0
PACKAGES=(
    "com.miui.dmregservice"                  # China Mobile Device Management / Richinfo Telemetry
    "com.mobiletools.systemhelper"          # China Unicom System Helper / Signal & App Telemetry
    "com.bsp.catchlog"                      # BSP Low-level System/Radio Log Dumper
    "com.miui.bugreport"                    # MIUI Bugreport & Remote Push Dumper
    "com.miui.uireporter"                   # UI Exception / Hang Log Reporter
    "com.xiaomi.security.onetrack"          # Security Center OneTrack Analytics
    "com.miui.greenguard"                   # Family Guard / Screen & App Monitoring
    "com.qualcomm.qti.devicestatisticsservice" # Qualcomm Battery & Hardware Telemetry
)

echo ""
echo "[+] Uninstalling pure telemetry packages for User 0..."
for pkg in "${PACKAGES[@]}"; do
    echo -n " -> Uninstalling $pkg: "
    adb shell "pm uninstall -k --user 0 $pkg 2>/dev/null && echo 'SUCCESS' || echo 'NOT INSTALLED / SKIPPED'"
    adb shell "am force-stop $pkg 2>/dev/null || true"
done

echo ""
echo "[+] Restricting Work Profile (User 10) background access for persistent system daemons..."
# In managed enterprise work profiles (User 10), adb cannot run pm uninstall due to cross-user DPC restrictions.
# We neutralize them via AppOps and NetPolicy blacklisting:
WORK_PACKAGES=(
    "com.mobiletools.systemhelper"
    "com.miui.analytics"
)

for pkg in "${WORK_PACKAGES[@]}"; do
    echo " -> Restricting $pkg under User 10..."
    adb shell "cmd appops set --user 10 $pkg RUN_IN_BACKGROUND ignore 2>/dev/null || true"
    adb shell "cmd appops set --user 10 $pkg RUN_ANY_IN_BACKGROUND ignore 2>/dev/null || true"
    adb shell "cmd appops set --user 10 $pkg FINE_LOCATION ignore 2>/dev/null || true"
    adb shell "cmd appops set --user 10 $pkg COARSE_LOCATION ignore 2>/dev/null || true"
    adb shell "cmd appops set --user 10 $pkg READ_PHONE_STATE ignore 2>/dev/null || true"
done

echo ""
echo "[+] Privacy debloat completed successfully."
