#!/usr/bin/env bash
# ==============================================================================
# motd-fatah Installer
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

echo -e "\n${C_CYAN}${C_BOLD}Installing motd-fatah (Mobile-Friendly Linux MOTD)...${RST}"

# 1. Create Directories
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/motd-fatah"
mkdir -p "$CONFIG_DIR" "$INSTALL_DIR"

# 2. Copy or Download executable
echo -e "${C_GRAY}  → Installing executable to ${INSTALL_DIR}/motd-fatah...${RST}"
if [[ -f "${SCRIPT_DIR}/motd.sh" ]]; then
    cp -f "${SCRIPT_DIR}/motd.sh" "${INSTALL_DIR}/motd-fatah"
else
    echo -e "${C_GRAY}  → Fetching motd.sh from GitHub...${RST}"
    curl -sSL "${RAW_BASE_URL}/motd.sh" -o "${INSTALL_DIR}/motd-fatah"
fi
chmod +x "${INSTALL_DIR}/motd-fatah"

# 3. Copy or Download configuration if not already present
if [[ -f "${CONFIG_DIR}/motd.conf" ]]; then
    echo -e "${C_YELLOW}  → Existing configuration found at ${CONFIG_DIR}/motd.conf (preserving)${RST}"
else
    echo -e "${C_GRAY}  → Installing default config to ${CONFIG_DIR}/motd.conf...${RST}"
    if [[ -f "${SCRIPT_DIR}/motd.conf" ]]; then
        cp -f "${SCRIPT_DIR}/motd.conf" "${CONFIG_DIR}/motd.conf"
    else
        echo -e "${C_GRAY}  → Fetching motd.conf from GitHub...${RST}"
        curl -sSL "${RAW_BASE_URL}/motd.conf" -o "${CONFIG_DIR}/motd.conf"
    fi
fi

# 4. Integrate into Login System
# Debian / Ubuntu dynamic update-motd.d
if [[ -d /etc/update-motd.d ]]; then
    echo -e "${C_GRAY}  → Configuring /etc/update-motd.d/99-motd-fatah...${RST}"
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
    echo -e "${C_GRAY}  → Configuring /etc/profile.d/motd-fatah.sh...${RST}"
    cat << 'PROFILE' > /etc/profile.d/motd-fatah.sh
# motd-fatah login banner
if [ -n "$PS1" ] && [ -z "$MOTD_FATAH_SHOWN" ] && [ -x /usr/local/bin/motd-fatah ]; then
    export MOTD_FATAH_SHOWN=1
    /usr/local/bin/motd-fatah
fi
PROFILE
    chmod +x /etc/profile.d/motd-fatah.sh
fi

echo -e "\n${C_GREEN}${C_BOLD}[✓] Installation completed successfully!${RST}"
echo -e "${C_GRAY}You can customize settings in: ${C_CYAN}${CONFIG_DIR}/motd.conf${RST}"
echo -e "${C_GRAY}Test it anytime by running:   ${C_CYAN}motd-fatah${RST}\n"

# Run a preview
/usr/local/bin/motd-fatah
