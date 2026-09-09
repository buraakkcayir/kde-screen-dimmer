# KDE Extra Dim Controller

A lightweight Bash wrapper for [`kdedimmer`](https://github.com/avivace/kdedimmer) that adds keyboard-friendly dimming steps and KDE Plasma OSD notifications. It is designed for KDE Plasma 6 on Wayland and starts the daemon only when a dimming action needs it.

This is an independent, unofficial project and is not affiliated with, endorsed by, or sponsored by KDE, the `kdedimmer` authors, Arch Linux, or any other trademark owner.

## Scope

The script controls software dimming through `kdedimmer`; it does not change hardware backlight brightness, install a desktop service, or provide a graphical settings application. It requires an active user DBus session and KDE Plasma's OSD service.

## Features

- Starts `kdedimmer` on demand.
- Persists the current dimming level in the user runtime directory.
- Changes dimming in configurable steps up to a configurable maximum.
- Displays feedback through KDE Plasma's native OSD service.
- Validates state input and reports dependency or DBus failures.

## Requirements

- KDE Plasma 6 running on Wayland.
- A user session with a writable `XDG_RUNTIME_DIR`.
- Bash 4 or newer, `pgrep`, and `mktemp`.
- The `kdedimmer` executable and its user DBus service.
- The `qdbus6` executable, normally provided by Qt 6 tools.

The tested installation path is Arch Linux or an Arch-based distribution. Other distributions may package the same dependencies under different names; package installation is not performed by this repository.

On Arch Linux, install the dependencies with:

```bash
paru -S kdedimmer
sudo pacman -S qt6-tools
```

If `paru` is not available, use another trusted AUR helper such as `yay`, or install `kdedimmer` according to its upstream documentation. Do not pipe untrusted install scripts directly into a shell.

## Installation

Clone or download the repository, then make the controller executable:

```bash
chmod +x kdedimmer-control.sh
```

No root permission is required to run the controller. Do not install it into a system directory unless you understand the ownership and update implications.

## Configuration

The script has two constants near the top of `kdedimmer-control.sh`:

| Setting | Default | Description |
| :--- | :--- | :--- |
| `MAX_DIM` | `95` | Maximum software dimming percentage. |
| `STEP` | `5` | Change applied by each `up` or `down` action. |

Runtime state is stored as `$XDG_RUNTIME_DIR/kdedimmer_state`. The state is session-local and is removed when dimming is turned off. The script falls back to `/run/user/$UID` only when `XDG_RUNTIME_DIR` is unset.

## Usage

Execute the script with one of the following arguments:

```bash
# Increase dimming by 5% (darker)
./kdedimmer-control.sh down   # or "more"

# Decrease dimming by 5% (brighter)
./kdedimmer-control.sh up     # or "less"

# Turn off dimming completely
./kdedimmer-control.sh off
```

Invalid actions and missing dependencies produce an error and a non-zero exit status.

## KDE Plasma shortcut setup

Go to **System Settings** -> **Shortcuts** -> **Add New** -> **Command**:

| Action | Shortcut (Example) | Command |
| :--- | :--- | :--- |
| **Dim Screen** | `Ctrl + Alt + Down` | `/path/to/kdedimmer-control.sh down` |
| **Brighten Screen** | `Ctrl + Alt + Up` | `/path/to/kdedimmer-control.sh up` |
| **Turn Off Dimmer** | `Ctrl + Alt + End` | `/path/to/kdedimmer-control.sh off` |

Use the actual path to your checkout in the commands above; `/path/to/kdedimmer-control.sh` is intentionally only a placeholder.

## Troubleshooting

- **`required command not found`:** Install the missing package and ensure its executable is on `PATH`.
- **`kdedimmer D-Bus interface is not available`:** Confirm that KDE Plasma and the user DBus session are running, then run the command from that session.
- **`runtime directory does not exist` or `is not writable`:** Check `XDG_RUNTIME_DIR`; it must point to the writable runtime directory for the current user.
- **No OSD appears:** Dimming can still work, but Plasma's OSD DBus service may be unavailable or disabled.
- **The script does not support X11 or non-KDE desktops:** Hardware brightness and other desktop integrations are outside this project's scope.

## Security notes

The script runs as the current user and does not require root privileges. It validates the persisted dimming value, rejects a symbolic-link state file, and writes state through a temporary file in the user runtime directory. Do not place the script or its state file in a shared writable directory.

## Uninstall

Remove the checkout and any KDE Plasma shortcut entries pointing to it. If present, remove the session state file:

```bash
rm -- "$XDG_RUNTIME_DIR/kdedimmer_state"
```

The `kdedimmer` package is managed separately by your operating system or package manager.

## Dependencies and licensing

This project contains original shell and documentation files and is distributed under the MIT License. `kdedimmer`, KDE Plasma, Qt, and DBus are external dependencies with their own licenses and trademarks. Refer to their upstream projects for their licensing terms.

## License

MIT License. See [`LICENSE`](LICENSE).
