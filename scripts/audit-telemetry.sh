#!/usr/bin/env bash
# Audit active telemetry, tracking daemons, and outbound connections on Android/HyperOS devices via ADB.

set -euo pipefail

echo "========================================================"
echo "    HyperOS / Android Telemetry & Tracking Audit        "
echo "========================================================"

DEVICE=$(adb get-serialno 2>/dev/null || true)
if [ -z "$DEVICE" ] || [ "$DEVICE" = "unknown" ]; then
    echo "[-] Error: No ADB device connected."
    exit 1
fi
echo "[+] Target Device Serial: $DEVICE"

echo ""
echo "=== 1. Active Telemetry & Tracking Processes ==="
adb shell "ps -A | grep -Ei 'dmregservice|systemhelper|onetrack|misight|catchlog|bugreport|uireporter|devicestatistics|greenguard|joyose|analytics|metoknlp|voicetrigger' || echo 'No matching processes running.'"

echo ""
echo "=== 2. Top Network Pollers (Lifetime Open Sessions) ==="
adb shell "dumpsys netstats 2>/dev/null | grep -A 25 'Top openSession callers:' || echo 'Netstats unavailable.'"

echo ""
echo "=== 3. Recent Telemetry / Wakeup Upload Logs (logcat) ==="
adb shell "logcat -d -t 2000 2>/dev/null | grep -Ei 'handleUpload|onetrack|misight|fxltsbl|dm\.wo\.com|statisticsWakeup' | tail -n 20 || echo 'No recent matching logs.'"

echo ""
echo "[+] Audit completed."
