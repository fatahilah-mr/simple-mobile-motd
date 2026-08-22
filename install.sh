#!/usr/bin/env bash
# ==============================================================================
# motd-fatah Installer (Interactive & Automated)
# GitHub: https://github.com/fatahilah/motd-fatah
# ==============================================================================

set -euo pipefail

# ANSI Colors
C_GREEN="\033[38;5;42m"
C_CYAN="\033[38;5;51m"
C_YELLOW="\033[38;5;214m"
C_RED="\033[38;5;196m"
C_GRAY="\033[38;5;242m"
C_BOLD="\033[1m"
RST="\033[0m"

# Repository raw URL fallback for curl/pipe installs
RAW_BASE_URL="https://raw.githubusercontent.com/fatahilah/motd-fatah/main"

# Root check
if [[ $EUID -ne 0 ]]; then
    echo -e "${C_RED}[!] Error: Please run this installer as root (sudo ./install.sh)${RST}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"

echo -e "\n${C_CYAN}${C_BOLD}======================================================${RST}"
echo -e "${C_CYAN}${C_BOLD}       📱 Installing motd-fatah (Linux MOTD)          ${RST}"
echo -e "${C_CYAN}${C_BOLD}======================================================${RST}\n"

# Interactive Configuration
CHOSEN_BANNER="FATAH"
CHOSEN_THEME="cyan"

# Check if interactive terminal or tty is available
IS_INTERACTIVE=false
TTY_DEV=""
if [[ -t 0 ]]; then
    IS_INTERACTIVE=true
elif [[ -c /dev/tty ]]; then
    IS_INTERACTIVE=true
    TTY_DEV="/dev/tty"
fi

if [[ "$IS_INTERACTIVE" == "true" ]]; then
    # 1. Ask for Banner Text
    echo -e "${C_YELLOW}✦ Konfigurasi Banner:${RST}"
    if [[ -n "$TTY_DEV" ]]; then
        read -r -p "$(echo -e "${C_GRAY}  Masukkan teks banner ASCII [Default: ${C_CYAN}FATAH${C_GRAY}]: ${RST}")" USER_BANNER < "$TTY_DEV" || true
    else
        read -r -p "$(echo -e "${C_GRAY}  Masukkan teks banner ASCII [Default: ${C_CYAN}FATAH${C_GRAY}]: ${RST}")" USER_BANNER || true
    fi
    [[ -n "${USER_BANNER:-}" ]] && CHOSEN_BANNER="${USER_BANNER^^}"

    # 2. Ask for Color Theme
    echo -e "\n${C_YELLOW}✦ Pilih Tema Warna:${RST}"
    echo -e "  1) ${C_CYAN}Cyan${RST} (Default)"
    echo -e "  2) \033[38;5;48mGreen\033[0m (Matrix)"
    echo -e "  3) \033[38;5;141mPurple\033[0m (Synthwave)"
    echo -e "  4) \033[38;5;39mBlue\033[0m (Classic)"
    echo -e "  5) \033[38;5;220mYellow\033[0m (Gold)"
    echo -e "  6) \033[38;5;201mRainbow\033[0m"
    echo -e "  7) \033[1;37mMono\033[0m"
    
    if [[ -n "$TTY_DEV" ]]; then
        read -r -p "$(echo -e "${C_GRAY}  Pilih nomor tema [1-7, Default: 1]: ${RST}")" THEME_CHOICE < "$TTY_DEV" || true
    else
        read -r -p "$(echo -e "${C_GRAY}  Pilih nomor tema [1-7, Default: 1]: ${RST}")" THEME_CHOICE || true
    fi

    case "${THEME_CHOICE:-1}" in
        2|green) CHOSEN_THEME="green" ;;
        3|purple) CHOSEN_THEME="purple" ;;
        4|blue) CHOSEN_THEME="blue" ;;
        5|yellow) CHOSEN_THEME="yellow" ;;
        6|rainbow) CHOSEN_THEME="rainbow" ;;
        7|mono) CHOSEN_THEME="mono" ;;
        1|cyan|*) CHOSEN_THEME="cyan" ;;
    esac
    echo ""
fi

# 1. Create Directories
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/motd-fatah"
mkdir -p "$CONFIG_DIR" "$INSTALL_DIR"

# 2. Copy or Download executable
echo -e "${C_GRAY}  → Memasang binary executable ke ${INSTALL_DIR}/motd-fatah...${RST}"
if [[ -f "${SCRIPT_DIR}/motd.sh" ]]; then
    cp -f "${SCRIPT_DIR}/motd.sh" "${INSTALL_DIR}/motd-fatah"
else
    echo -e "${C_GRAY}  → Mengunduh motd.sh dari GitHub...${RST}"
    curl -sSL "${RAW_BASE_URL}/motd.sh" -o "${INSTALL_DIR}/motd-fatah"
fi
chmod +x "${INSTALL_DIR}/motd-fatah"

# 3. Copy or Download configuration
echo -e "${C_GRAY}  → Membuat file konfigurasi di ${CONFIG_DIR}/motd.conf...${RST}"
if [[ -f "${SCRIPT_DIR}/motd.conf" ]]; then
    cp -f "${SCRIPT_DIR}/motd.conf" "${CONFIG_DIR}/motd.conf"
else
    curl -sSL "${RAW_BASE_URL}/motd.conf" -o "${CONFIG_DIR}/motd.conf"
fi

# Apply user choices to configuration
sed -i "s/^BANNER_TEXT=.*/BANNER_TEXT=\"${CHOSEN_BANNER}\"/" "${CONFIG_DIR}/motd.conf"
sed -i "s/^THEME=.*/THEME=\"${CHOSEN_THEME}\"/" "${CONFIG_DIR}/motd.conf"

# 4. Integrate into Login System
# Debian / Ubuntu dynamic update-motd.d
if [[ -d /etc/update-motd.d ]]; then
    echo -e "${C_GRAY}  → Mengintegrasikan ke /etc/update-motd.d/99-motd-fatah...${RST}"
    cat << 'RUNNER' > /etc/update-motd.d/99-motd-fatah
#!/usr/bin/env bash
/usr/local/bin/motd-fatah
RUNNER
    chmod +x /etc/update-motd.d/99-motd-fatah

    # Disable noisy default Ubuntu/Debian MOTDs if present
    for noisy in 10-help-text 50-motd-news 80-esm 88-esm-announce 90-updates-available; do
        if [[ -f "/etc/update-motd.d/${noisy}" && -x "/etc/update-motd.d/${noisy}" ]]; then
            chmod -x "/etc/update-motd.d/${noisy}" 2>/dev/null || true
        fi
    done
fi

# Universal profile.d hook (for interactive bash login sessions)
if [[ -d /etc/profile.d ]]; then
    echo -e "${C_GRAY}  → Mengintegrasikan ke /etc/profile.d/motd-fatah.sh...${RST}"
    cat << 'PROFILE' > /etc/profile.d/motd-fatah.sh
# motd-fatah login banner
if [ -n "$PS1" ] && [ -z "$MOTD_FATAH_SHOWN" ] && [ -x /usr/local/bin/motd-fatah ]; then
    export MOTD_FATAH_SHOWN=1
    /usr/local/bin/motd-fatah
fi
PROFILE
    chmod +x /etc/profile.d/motd-fatah.sh
fi

echo -e "\n${C_GREEN}${C_BOLD}[✓] Instalasi motd-fatah selesai!${RST}"
echo -e "${C_GRAY}Konfigurasi tersimpan di: ${C_CYAN}${CONFIG_DIR}/motd.conf${RST}"
echo -e "${C_GRAY}Preview MOTD saat ini:${RST}\n"

# Run a preview
/usr/local/bin/motd-fatah
