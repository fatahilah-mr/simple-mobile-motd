#!/usr/bin/env bash
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

if [[ $EUID -ne 0 ]]; then
    echo -e "${C_RED}[!] Error: Please run this uninstaller as root (sudo ./uninstall.sh)${RST}"
    exit 1
fi

echo -e "\n${C_YELLOW}${C_BOLD}Uninstalling motd-fatah...${RST}"

# 1. Remove binary
if [[ -f /usr/local/bin/motd-fatah ]]; then
    echo -e "${C_GRAY}  → Removing /usr/local/bin/motd-fatah...${RST}"
    rm -f /usr/local/bin/motd-fatah
fi

# 2. Remove MOTD hooks
if [[ -f /etc/update-motd.d/99-motd-fatah ]]; then
    echo -e "${C_GRAY}  → Removing /etc/update-motd.d/99-motd-fatah...${RST}"
    rm -f /etc/update-motd.d/99-motd-fatah
fi

if [[ -f /etc/profile.d/motd-fatah.sh ]]; then
    echo -e "${C_GRAY}  → Removing /etc/profile.d/motd-fatah.sh...${RST}"
    rm -f /etc/profile.d/motd-fatah.sh
fi

# 3. Clean temporary cache
rm -f /tmp/.motd_public_ip

# 4. Handle Configuration
if [[ -d /etc/motd-fatah ]]; then
    rm -rf /etc/motd-fatah
    echo -e "${C_GRAY}  → Removed /etc/motd-fatah configuration directory.${RST}"
fi

echo -e "\n${C_GREEN}${C_BOLD}[✓] motd-fatah has been successfully uninstalled.${RST}\n"
