#!/bin/bash

# -----------------------------------------------------
# KALI NETHUNTER: SWITCH TO CHROMIUM
# Use this if Firefox refuses to play video/audio
# -----------------------------------------------------

R='\033[1;31m' # Red
G='\033[1;32m' # Green
Y='\033[1;33m' # Yellow
NC='\033[0m'   # No Color

echo -e "${Y}[*] Cleaning up Firefox...${NC}"
sudo apt remove -y firefox-esr firefox
rm -rf ~/.mozilla/firefox

echo -e "${Y}[*] Installing Chromium Browser...${NC}"
sudo apt update
sudo apt install -y chromium

# -----------------------------------------------------
# THE FIX: CREATE A SAFE LAUNCHER
# Chromium will NOT open in rootless mode without
# the --no-sandbox flag. We create a shortcut for it.
# -----------------------------------------------------
echo -e "${Y}[*] Creating 'chromium-safe' launcher...${NC}"

cat <<EOF | sudo tee /usr/bin/chromium-safe
#!/bin/bash
# Wrapper to run Chromium safely in NetHunter Rootless
echo "Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1 > /dev/null 2>&1

echo "Launching Chromium..."
# --no-sandbox: Required for Termux/Proot
# --disable-gpu: Prevents black screen on some VNCs
# --disable-software-rasterizer: Improves stability
/usr/bin/chromium --no-sandbox --disable-gpu --disable-software-rasterizer --test-type "\$@"
EOF

# Make it executable
sudo chmod +x /usr/bin/chromium-safe

# -----------------------------------------------------
# MENU SHORTCUT FIX (Optional)
# This attempts to fix the desktop icon to use our safe mode
# -----------------------------------------------------
DESKTOP_FILE="/usr/share/applications/chromium.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    echo -e "${Y}[*] Patching Desktop Icon...${NC}"
    sudo sed -i 's|Exec=/usr/bin/chromium %U|Exec=/usr/bin/chromium-safe %U|g' "$DESKTOP_FILE"
    sudo sed -i 's|Exec=chromium %U|Exec=chromium-safe %U|g' "$DESKTOP_FILE"
fi

echo " "
echo -e "${G}[SUCCESS] Chromium Installed.${NC}"
echo -e "${Y}To open the browser, type this command:${NC}"
echo -e "${G}chromium-safe${NC}"
echo -e "${Y}(Or use the menu icon, which has been patched)${NC}"
