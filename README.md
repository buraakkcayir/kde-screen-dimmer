# KDE Extra Dim Controller

A lightweight shell wrapper for `kdedimmer` on **KDE Plasma 6 (Wayland)** providing on-demand daemon startup, state persistence, step-based brightness stepping, and native KDE OSD notifications.

---

## ✨ Features

- **On-Demand (Lazy) Startup:** Starts the `kdedimmer` daemon only when needed, avoiding unnecessary background memory usage.
- **Native Plasma 6 OSD:** Displays real-time visual feedback via KDE's native D-Bus On-Screen Display (`org.kde.osdService`).
- **Smooth Stepping:** Increments/decrements dimming in 5% steps with a configurable cap (up to 95%).
- **Clean Turn-off:** Gracefully shuts off dimming and unlinks temporary runtime state files.

---

## 📦 Prerequisites

1. **kdedimmer:** Make sure `kdedimmer` is installed from the AUR:
```bash
paru -S kdedimmer
```

2. **Qt6 DBus Utilities:** `qdbus6` (standard in KDE Plasma 6 installations):
```bash
sudo pacman -S qt6-tools
```

---

## 🚀 Usage

Execute the script with one of the following arguments:

```bash
# Increase dimming by 5% (Darker)
./kdedimmer-control.sh more   # or "down"

# Decrease dimming by 5% (Brighter)
./kdedimmer-control.sh less   # or "up"

# Turn off dimming completely
./kdedimmer-control.sh off
```

---

## ⌨️ KDE Plasma Shortcut Setup

Go to **System Settings** -> **Shortcuts** -> **Add New** -> **Command**:

| Action | Shortcut (Example) | Command |
| :--- | :--- | :--- |
| **Dim Screen** | `Ctrl + Alt + Down` | `/path/to/kdedimmer-control.sh down` |
| **Brighten Screen** | `Ctrl + Alt + Up` | `/path/to/kdedimmer-control.sh up` |
| **Turn Off Dimmer** | `Ctrl + Alt + End` | `/path/to/kdedimmer-control.sh off` |

---

## 📜 License
MIT License
