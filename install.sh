#!/data/data/com.termux/files/usr/bin/bash

# -----------------------------------------------------
# COLOR DEFINITIONS
# -----------------------------------------------------
R='\033[1;31m' # Red
G='\033[1;32m' # Green
Y='\033[1;33m' # Yellow
B='\033[1;34m' # Blue
C='\033[1;36m' # Cyan
W='\033[1;37m' # White
NC='\033[0m'   # No Color

# -----------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------
banner() {
    clear
    printf "${R}    ██╗  ██╗ █████╗ ██╗     ██╗${NC}\n"
    printf "${Y}    ██║ ██╔╝██╔══██╗██║     ██║${NC}\n"
    printf "${G}    █████╔╝ ███████║██║     ██║${NC}\n"
    printf "${C}    ██╔═██╗ ██╔══██║██║     ██║${NC}\n"
    printf "${B}    ██║  ██╗██║  ██║███████╗██║${NC}\n"
    printf "${B}    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝${NC}\n"
    echo " "
    printf "${C}    Kali Nethunter Installer${NC}\n"
    printf "${Y}    Author : Mahesh Technicals${NC}\n"
    echo " "
    echo "-------------------------------------------------------"
}

msg_info() {
    echo -e "${G}[+] ${W}$1${NC}"
}

msg_ask() {
    echo -e "${Y}[?] ${W}$1${NC}"
}

msg_err() {
    echo -e "${R}[!] ${W}$1${NC}"
}

# -----------------------------------------------------
# 1. CLEANUP & RESTORE TERMUX DEFAULTS
# -----------------------------------------------------
# Remove any previous auto-login or auto-vnc lines so Termux opens normally
sed -i '/( kali vnc & )/d' "$PREFIX/etc/bash.bashrc"
sed -i '/neofetch/d' "$PREFIX/etc/bash.bashrc"
sed -i '/termux-wake-lock/d' "$PREFIX/etc/bash.bashrc"
sed -i '/kali -r/d' "$PREFIX/etc/bash.bashrc"
sed -i '/clear/d' "$PREFIX/etc/bash.bashrc"

# -----------------------------------------------------
# 2. INSTALL DEPENDENCIES
# -----------------------------------------------------
banner
msg_info "Checking dependencies..."
pkg install proot bsdtar libxml2 axel -y > /dev/null 2>&1
msg_info "Dependencies installed."

# -----------------------------------------------------
# 3. DETECT ARCHITECTURE
# -----------------------------------------------------
case $(getprop ro.product.cpu.abi) in
    arm64-v8a) SYS_ARCH=arm64 ;;
    armeabi|armeabi-v7a) SYS_ARCH=armhf ;;
    x86_64) SYS_ARCH=amd64 ;;
    x86|i686) SYS_ARCH=i386 ;;
    *) msg_err "Unsupported Architecture!"; exit 1 ;;
esac

DIR="kali-${SYS_ARCH}"

# -----------------------------------------------------
# 4. SELECT VERSION
# -----------------------------------------------------
banner
echo -e "${C}[*] Architecture : ${W}$SYS_ARCH"
echo -e "${C}[*] Install Path : ${W}$DIR"
echo " "
echo -e "${G}[1]${W} Kali NetHunter Full"
echo -e "${G}[2]${W} Kali NetHunter Minimal"
echo -e "${G}[3]${W} Kali NetHunter Nano"
echo " "
read -rp "$(echo -e ${Y}"Select the number to install: "${NC})" wimg

case $wimg in
    1) wimg="full" ;;
    2) wimg="minimal" ;;
    3) wimg="nano" ;;
    *) wimg="minimal" ;;
esac

IMAGE_NAME="kali-nethunter-rootfs-${wimg}-${SYS_ARCH}.tar.xz"
NM="kali"

# -----------------------------------------------------
# 5. SMART DOWNLOAD LOGIC
# -----------------------------------------------------
echo " "
if [ -f "$IMAGE_NAME" ]; then
    msg_ask "File '$IMAGE_NAME' already exists."
    read -rp "$(echo -e ${Y}"Do you want to re-download it? (y/n): "${NC})" redownload
    if [[ "$redownload" == "y" || "$redownload" == "Y" ]]; then
        msg_info "Removing old file and re-downloading..."
        rm -f "$IMAGE_NAME"
        axel -o "$IMAGE_NAME" "https://kali.download/nethunter-images/current/rootfs/$IMAGE_NAME"
    else
        msg_info "Using existing file..."
    fi
else
    msg_info "Downloading '$IMAGE_NAME'..."
    axel -o "$IMAGE_NAME" "https://kali.download/nethunter-images/current/rootfs/$IMAGE_NAME"
fi

# Check file integrity
echo " "
msg_info "Calculating Hash (MD5)..."
md5sum "$IMAGE_NAME"

# -----------------------------------------------------
# 6. EXTRACTION (Update Mode - No Data Loss)
# -----------------------------------------------------
echo " "
if [ -d "$DIR" ]; then
    msg_info "Existing installation found ($DIR)."
    msg_info "Overwriting system files with new image..."
    msg_info "NOTE: User data will be preserved."
else
    msg_info "Creating new installation in '$DIR'..."
fi

msg_info "Extracting rootfs... (This may take a while)"
proot --link2symlink bsdtar -xpJf "$IMAGE_NAME" >/dev/null 2>&1

# -----------------------------------------------------
# 7. CREATE KALI LAUNCHER
# -----------------------------------------------------
cat > "$PREFIX/bin/$NM" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash

cd "$HOME"
unset LD_PRELOAD

if [ ! -f $DIR/root/.version ]; then
    touch $DIR/root/.version
fi

user="$NM"
home="/home/\$user"
start="sudo -u kali /bin/bash"

if grep -q "kali" ${DIR}/etc/passwd; then
    KALIUSR="1";
else
    KALIUSR="0";
fi

if [[ \$KALIUSR == "0" || ("\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R")) ]];then
    user="root"
    home="/\$user"
    start="/bin/bash --login"
    if [[ "\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R") ]];then
        shift
    fi
fi

cmdline="proot \\
        --link2symlink -p \\
        -0 \\
        -r $DIR \\
        -b /dev \\
        -b /proc \\
        -b /sdcard \\
        -b $DIR\$home:/dev/shm \\
        -w \$home \\
           /usr/bin/env -i \\
           HOME=\$home \\
           PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin \\
           TERM=\$TERM \\
           LANG=C.UTF-8 \\
           \$start"

cmd="\$@"
if [ "\$#" == "0" ];then
    exec \$cmdline
else
    \$cmdline -c "\$cmd"
fi
EOF
chmod 755 "$PREFIX/bin/$NM"

# Modify .bash_profile
sed -i '/if/,/fi/d' "$DIR/root/.bash_profile"

# Set SUID for sudo and su
chmod +s "$DIR/usr/bin/sudo"
chmod +s "$DIR/usr/bin/su"

# Fix DNS
cat > "$DIR/etc/resolv.conf" << EOF
nameserver 9.9.9.9
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# Fix Sudoers
cat > "$DIR/etc/sudoers.d/$NM" << EOF
$NM    ALL=(ALL:ALL) ALL
EOF

# Clean internal bashrc
sed -i '/neofetch/d' "$DIR/etc/bash.bashrc"

# Configure sudo.conf
cat > "$DIR/etc/sudo.conf" << EOF
Set disable_coredump false
EOF

# -----------------------------------------------------
# 8. CREATE KEX COMMAND (With Session Cleanup)
# -----------------------------------------------------
cat > "$DIR/usr/bin/kex" << 'EOF'
#!/bin/bash

function help() {
    echo "Usage: kex [passwd | kill | start]"
    echo "  passwd : Set VNC password"
    echo "  kill   : Kill all VNC processes"
    echo "  start  : Start VNC server (default)"
}

if ! command -v vncserver &> /dev/null; then
    echo "[!] TigerVNC not found."
    echo "[*] Installing TigerVNC..."
    sudo apt update && sudo apt install tigervnc-standalone-server -y
fi

case "$1" in
    passwd)
        vncpasswd
        ;;
    kill)
        echo "[*] Killing VNC Server..."
        vncserver -kill :* > /dev/null 2>&1
        rm -rf /tmp/.X*-lock /tmp/.X11-unix > /dev/null 2>&1
        echo "[+] VNC Server Stopped."
        ;;
    start|"")
        echo "[*] Cleaning old sessions..."
        rm -rf ~/.cache/sessions
        echo "[*] Starting VNC Server..."
        vncserver
        echo "[+] VNC Started."
        echo "[!] Note: If this is your first time, run 'kex passwd' first."
        ;;
    *)
        help
        ;;
esac
EOF
chmod 755 "$DIR/usr/bin/kex"

# -----------------------------------------------------
# 9. CREATE UNINSTALLER
# -----------------------------------------------------
cat > "$PREFIX/bin/$NM-uninstall" << EOF
#!/data/data/com.termux/files/usr/bin/bash

rm -rf "$HOME/$DIR"
rm -f "$PREFIX/bin/$NM"
# Remove startup configs
sed -i '/termux-wake-lock/d' "$PREFIX/etc/bash.bashrc"
sed -i '/clear/d' "$PREFIX/etc/bash.bashrc"
sed -i '/$NM -r/d' "$PREFIX/etc/bash.bashrc"
sed -i '/( kali vnc & )/d' "$PREFIX/etc/bash.bashrc"
rm -f "$PREFIX/bin/$NM-uninstall"
EOF
chmod 755 "$PREFIX/bin/$NM-uninstall"

# Fix Groups
USRID=$(id -u)
GRPID=$(id -g)
"$NM" -r usermod -u "$USRID" "$NM" >/dev/null 2>&1
"$NM" -r groupmod -g "$GRPID" "$NM" >/dev/null 2>&1

# -----------------------------------------------------
# 10. CLEANUP PROMPT & EXIT
# -----------------------------------------------------
# Auto-delete the install script itself
rm -f install.sh

echo " "
echo "-------------------------------------------------------"
msg_ask "Do you want to delete the downloaded image file?"
echo -e "    ${W}File: $IMAGE_NAME${NC}"
read -rp "$(echo -e ${Y}"    (y/n): "${NC})" del_opt

if [[ "$del_opt" == "y" || "$del_opt" == "Y" ]]; then
    rm -f "$IMAGE_NAME"
    msg_info "Image file deleted."
else
    msg_info "Image file kept."
fi

banner
msg_info "Installation Complete!"
echo " "
echo -e "${Y}[*] COMMANDS TO RUN:${NC}"
echo -e "    1. Type: ${G}kali${NC}    (Login as User)"
echo -e "    2. Type: ${G}kali -r${NC} (Login as Root)"
echo " "
echo -e "${Y}[*] VNC SETUP (INSIDE KALI):${NC}"
echo -e "    - Run: ${C}kex passwd${NC} (set password)"
echo -e "    - Run: ${C}kex &${NC}      (start server)"
echo -e "    - Run: ${C}kex kill${NC}   (stop server)"
echo " "
