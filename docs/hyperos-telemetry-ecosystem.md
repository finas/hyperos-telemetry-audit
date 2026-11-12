# Xiaomi HyperOS Telemetry & Logging Ecosystem Survey

This survey catalogs the background telemetry, diagnostic log-dumpers, and cloud reporting services identified during the device audit of **Xiaomi 15 (Model 24129PN74C)** running Xiaomi HyperOS.

---

## Catalog of Telemetry & Log Catchers

### 1. Pure Log Dumpers & Remote Reporters

| Package | APK Location | Role & Behavior | Risk Level |
| :--- | :--- | :--- | :--- |
| **`com.bsp.catchlog`** | `/product/app/CatchLog` | Triggered by telephony secret dial codes (`SECRET_CODE`); dumps kernel logs, radio modem traces, and system heap memory to `/sdcard`. | High (System dump) |
| **`com.miui.bugreport`** | `/data/app/.../com.miui.bugreport...` | Listens to Xiaomi MiPush commands (`BugreportPushMessageReceiver`) to silently package bugreports and upload to Xiaomi Distributed File System (`DFSReceiver`). | High (Silent cloud upload) |
| **`com.miui.uireporter`** | `/product/app/MIUIReporter` | Monitors ANRs (Application Not Responding) and UI freezes; triggers automated log packages and sends them to `com.miui.bugreport`. | Medium |
| **`com.xiaomi.security.onetrack`** | `/product/app/SecurityOnetrackService` | Autostarts on `BOOT_COMPLETED` (`OneTrackReceiver`). Tracks user interaction, feature clicks, and scan outcomes in MIUI Security Center. | High (User behavior tracking) |

---

### 2. Live Background Telemetry & Audio Upload Services

| Package | Process / PID | Observed Live Log Activity |
| :--- | :--- | :--- |
| **`com.miui.voicetrigger`** | PID 31701 | **Wakeup Audio Upload**: Monitors microphone audio snippets. When false wakeups or suspect triggers occur, it formats and attempts to upload the audio recording and stats (`handleUploadWakeupFile`, `isRestrictionUploadFile`). |
| **`com.miui.misightservice` & `misight`** | PID 15743 & 2569 | **System Event Pipeline**: Native daemon and service intercepting cellular RAT switches (`'{"fromRAT":20,"toRAT":20}'`), performance faults, and log dumps. |
| **`com.qualcomm.qti.devicestatisticsservice`** | PID 26364 | **Hardware & Battery Telemetry**: Logs battery health, charging voltage, charger types, and power curves. |
| **`com.xiaomi.metoknlp`** | PID 26355 | **Location Provider**: Listens to `SCREEN_ON` and network state changes, bundling Amap (`com.amap.location.signal`) and Xiaomi location signals to resolve device positioning. |

---

### 3. Cloud Strategy & Policy Services

* **`com.xiaomi.joyose`**:
  Gaming optimization and cloud policy engine. Periodically contacts `api.joyose.xiaomi.com` to fetch dynamic throttling limits, frame rate control configs, and report application launch events.
* **`com.miui.greenguard` (风筝守护)**:
  Device supervision package. Monitors `com.xiaomi.market.DOWNLOAD_INSTALL_RESULT` to intercept all newly installed packages, tracks application screen time, and allows remote location surveillance via MiPush.
* **`com.miui.cleanmaster`**:
  Cheetah Mobile cleaning engine embedded in MIUI Cleaner. Downloads remote junk definitions and uploads local cache statistics.
* **`com.miui.contentcatcher`**:
  Screen and clipboard content scraper used for service recommendations and portal features.
