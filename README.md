# 🐉 Kali Linux NetHunter Installer for Termux

<!-- Badges -->
![Version](https://img.shields.io/badge/version-3.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Termux-green.svg)
![Author](https://img.shields.io/badge/author-Mahesh%20Technicals-orange.svg)

<!-- Header Image -->
![Kali NetHunter Banner](res/NH.jpg)

---

**An advanced, automated installer to run Kali Linux NetHunter (Rootless) on Android devices using Termux.**

This script installs a full Kali Linux environment without requiring root access. It comes pre-configured with audio support (PulseAudio), a custom VNC manager (`kex`), and smart update features that preserve your data during upgrades.

---

## ✨ Key Features

* **🔥 No Root Required**: Uses `proot` to simulate a root environment.
* **🔊 Auto Sound Fix**: Integrated PulseAudio configuration. Audio from Kali works instantly on your Android device.
* **🧠 Smart Download**: Automatically detects if the rootfs is already downloaded to save data.
* **🔄 Smart Update**: Updates system files without deleting your personal user data (`/home` directory).
* **🖥️ Kex Manager**: A custom `kex` command to easily manage VNC sessions (Start, Stop, Password).
* **📱 Multi-Arch Support**: Automatically detects `arm64`, `armhf`, `amd64`, or `i386`.

---

## 📋 Requirements

Before you begin, ensure your device meets the following requirements:

1.  **Storage**: At least **15-20 GB** of free internal storage.
2.  **Internet**: A stable connection (WiFi recommended) for the initial download (~1.5GB - 3GB depending on version).
3.  **Apps**: You need the following apps installed:

| App Name | Description | Download Link |
| :--- | :--- | :--- |
| **Termux** | The terminal emulator | [Download via GitHub](https://github.com/termux/termux-app/releases/latest) |
| **Termux API** | Hardware bridge | [Download via GitHub](https://github.com/termux/termux-api/releases/latest) |
| **VNC Viewer** | To view the desktop (GUI) | [Download via Play Store](https://play.google.com/store/apps/details?id=com.realvnc.viewer.android) |

---

## 🚀 Installation

Open **Termux** and run the following commands one by one:

### 1. Update Termux
Update your repositories to ensure everything runs smoothly.
```bash
apt update && apt upgrade -y
```

### 2. Download Installer
Fetch the installation script from the repository.
```bash
wget [https://raw.githubusercontent.com/MaheshTechnicals/Kali-Linux-Termux/refs/heads/main/install.sh](https://raw.githubusercontent.com/MaheshTechnicals/Kali-Linux-Termux/refs/heads/main/install.sh)
```

### 3. Grant Permissions
Make the script executable.
```bash
chmod +x install.sh
```

### 4. Run Installer
Execute the script.
```bash
bash install.sh
```

> **Note:** When asked, select **Option 1** for the **Full Version** to get all tools and the desktop environment.

---

## 🎮 Usage Guide

Once installed, you can use the following commands inside Termux:

### 🟢 Basic Commands
| Command | Description |
| :--- | :--- |
| `kali` | Login to Kali Linux as a standard user (Recommended). |
| `kali -r` | Login to Kali Linux as **Root**. |

### 🖥️ Desktop (VNC) Commands
We have included a custom tool called `kex` to manage your Graphical User Interface (GUI).

1.  **Login to Kali** first (`kali`).
2.  Run the following commands inside Kali:

| Command | Description |
| :--- | :--- |
| `kex passwd` | **Run this first.** Set up your VNC password (6-8 characters). |
| `kex &` | Start the VNC Server. |
| `kex kill` | Stop/Kill all running VNC sessions (useful if it crashes). |

---

## 📡 How to Connect to GUI (Desktop)

1.  Start the server inside Kali: `kex &`
2.  Open the **VNC Viewer** app on your phone.
3.  Create a new connection with these details:
    * **Address:** `127.0.0.1:5901` (or `localhost:5901`)
    * **Name:** Kali Linux
4.  Click **Connect**.
5.  Enter the password you set using `kex passwd`.

---

## 🛠️ Troubleshooting

* **Audio not working?**
    * The script automatically sets up PulseAudio. If it stops, simply restart Termux. The script ensures the audio server starts every time Termux opens.
* **Download failed?**
    * Run the script again. It will ask if you want to resume or re-download.
* **"Signal 9" Error?**
    * This usually means the Android system killed Termux to save battery. Check your phone settings and allow Termux to run in the background (disable battery optimization for Termux).

---

## 👨‍💻 Author

**Mahesh Technicals**
* Created and maintained by Mahesh Technicals.
* Script optimized for stability and ease of use.

---

*Disclaimer: This tool is for educational purposes and ethical hacking only. The author is not responsible for misuse.*
