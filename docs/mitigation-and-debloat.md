# Mitigation & Debloat Guide

This guide details how to remove telemetry services, audit active background loggers, and handle cross-user work profile restrictions on Xiaomi HyperOS devices.

---

## 1. Automated Execution

Run the bundled shell scripts directly:

```bash
# 1. Audit active processes, sockets, and netstats sessions
./scripts/audit-telemetry.sh

# 2. Debloat pure telemetry and log-collecting packages
./scripts/debloat-user0.sh
```

---

## 2. Manual Package Removal (User 0)

To remove pure telemetry and log-collecting apps while preserving user data (via `-k` flag):

```bash
# China Mobile Device Management & Richinfo Telemetry
adb shell "pm uninstall -k --user 0 com.miui.dmregservice"

# China Unicom Telemetry & Signal Surveyor
adb shell "pm uninstall -k --user 0 com.mobiletools.systemhelper"

# Low-level BSP Log Catcher
adb shell "pm uninstall -k --user 0 com.bsp.catchlog"

# MIUI Bug Report & Remote DFS Cloud Uploader
adb shell "pm uninstall -k --user 0 com.miui.bugreport"

# UI ANR & Exception Reporter
adb shell "pm uninstall -k --user 0 com.miui.uireporter"

# Security Center Behavior Analytics
adb shell "pm uninstall -k --user 0 com.xiaomi.security.onetrack"

# Family Guard / App & Screen Time Surveillance
adb shell "pm uninstall -k --user 0 com.miui.greenguard"

# Qualcomm Hardware & Battery Statistics
adb shell "pm uninstall -k --user 0 com.qualcomm.qti.devicestatisticsservice"
```

### Optional Packages (Depending on Personal Usage)

* **Voice Wakeup audio recording (`com.miui.voicetrigger`)**:
  ```bash
  adb shell "pm uninstall -k --user 0 com.miui.voicetrigger"
  ```
* **Joyose Cloud Throttling (`com.xiaomi.joyose`)**:
  ```bash
  adb shell "pm uninstall -k --user 0 com.xiaomi.joyose"
  ```
* **Clean Master Cloud Definitions (`com.miui.cleanmaster`)**:
  ```bash
  adb shell "pm uninstall -k --user 0 com.miui.cleanmaster"
  ```

---

## 3. Handling Work Profile / Managed Enterprise Profiles (User 10)

On devices with an enterprise Work Profile (managed by Google Cloud DPC or Intune), running `pm uninstall --user 10` fails with:
```text
SecurityException: Shell does not have permission to access user 10
```

Because ADB cannot directly unregister packages in managed profiles, use **AppOps** and **NetPolicy** to neutralize their capabilities:

```bash
# Blacklist background network connectivity
adb shell "cmd netpolicy add restrict-background-blacklist 1010099" # SystemHelper UID
adb shell "cmd netpolicy add restrict-background-blacklist 1010146" # Analytics UID

# Revoke execution and sensitive permissions
for pkg in com.mobiletools.systemhelper com.miui.analytics; do
    adb shell "cmd appops set --user 10 $pkg RUN_IN_BACKGROUND ignore"
    adb shell "cmd appops set --user 10 $pkg RUN_ANY_IN_BACKGROUND ignore"
    adb shell "cmd appops set --user 10 $pkg FINE_LOCATION ignore"
    adb shell "cmd appops set --user 10 $pkg COARSE_LOCATION ignore"
    adb shell "cmd appops set --user 10 $pkg READ_PHONE_STATE ignore"
    adb shell "cmd appops set --user 10 $pkg WIFI_SCAN ignore"
    adb shell "cmd appops set --user 10 $pkg BLUETOOTH_CONNECT ignore"
done
```

---

## 4. How to Restore Packages

If any system functionality is needed in the future, packages can be restored instantly without reflashing:

```bash
adb shell "cmd package install-existing --user 0 <package_name>"
```
