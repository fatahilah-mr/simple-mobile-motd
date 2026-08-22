#!/data/data/com.termux/files/usr/bin/env bash
# ==============================================================================
# motd-fatah Uninstaller
# ==============================================================================

set -euo pipefail

C_GREEN="\033[38;5;42m"
C_CYAN="\033[38;5;51m"
C_YELLOW="\033[38;5;214m"
C_RED="\033[38;5;196m"
C_GRAY="\033[38;5;242m"
C_BOLD="\033[1m"
RST="\033[0m"

PREFIX="${PREFIX:-}"
if [[ -z "$PREFIX" && $EUID -ne 0 ]]; then
    echo -e "${C_RED}[!] Error: Please run this uninstaller as root (sudo ./uninstall.sh)${RST}"
    exit 1
fi

if [[ -n "$PREFIX" ]]; then
    INSTALL_DIR="${PREFIX}/bin"
    CONFIG_DIR="${PREFIX}/etc/motd-fatah"
else
    INSTALL_DIR="/usr/local/bin"
    CONFIG_DIR="/etc/motd-fatah"
fi

echo -e "\n${C_YELLOW}${C_BOLD}Uninstalling motd-fatah...${RST}"

# 1. Remove binary
if [[ -f "${INSTALL_DIR}/motd-fatah" ]]; then
    echo -e "${C_GRAY}  → Removing ${INSTALL_DIR}/motd-fatah...${RST}"
    rm -f "${INSTALL_DIR}/motd-fatah"
fi

# 2. Remove MOTD hooks
if [[ -n "$PREFIX" ]]; then
    if [[ -f "${PREFIX}/etc/motd.sh" ]]; then
        echo -e "${C_GRAY}  → Removing ${PREFIX}/etc/motd.sh...${RST}"
        rm -f "${PREFIX}/etc/motd.sh"
    fi
    for rc in "${PREFIX}/etc/zshrc" "${PREFIX}/etc/bash.bashrc"; do
        if [[ -f "$rc" ]]; then
            sed -i '/motd-fatah/d' "$rc"
        fi
    done
fi

if [[ -f /etc/update-motd.d/99-motd-fatah ]]; then
    echo -e "${C_GRAY}  → Removing /etc/update-motd.d/99-motd-fatah...${RST}"
    rm -f /etc/update-motd.d/99-motd-fatah
fi

if [[ -f /etc/profile.d/motd-fatah.sh ]]; then
    echo -e "${C_GRAY}  → Removing /etc/profile.d/motd-fatah.sh...${RST}"
    rm -f /etc/profile.d/motd-fatah.sh
fi

# 3. Clean temporary cache
rm -f "${TMPDIR:-/tmp}/.motd_public_ip"

# 4. Handle Configuration
if [[ -d "$CONFIG_DIR" ]]; then
    rm -rf "$CONFIG_DIR"
    echo -e "${C_GRAY}  → Removed ${CONFIG_DIR} configuration directory.${RST}"
fi

echo -e "\n${C_GREEN}${C_BOLD}[✓] motd-fatah has been successfully uninstalled.${RST}\n"
