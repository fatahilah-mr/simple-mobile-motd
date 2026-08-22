#!/data/data/com.termux/files/usr/bin/env bash
# ==============================================================================
# motd-fatah - Mobile-Friendly Responsive Linux MOTD
# GitHub: https://github.com/fatahilah-mr/simple-mobile-motd
# ==============================================================================

# Ensure bash environment & exit gracefully on error
set -o pipefail 2>/dev/null || true

# --- Load Configuration ---
CONFIG_FILE="${PREFIX:-}/etc/motd-fatah/motd.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
elif [[ -f "/etc/motd-fatah/motd.conf" ]]; then
    # shellcheck source=/dev/null
    source "/etc/motd-fatah/motd.conf"
elif [[ -f "${SCRIPT_DIR}/motd.conf" ]]; then
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/motd.conf"
fi

# Set defaults if not set in config
BANNER_STYLE="${BANNER_STYLE:-mini}"
BANNER_TEXT="${BANNER_TEXT:-FATAH}"
THEME="${THEME:-cyan}"
BAR_WIDTH="${BAR_WIDTH:-auto}"
BAR_FILLED="${BAR_FILLED:-◆}"
BAR_EMPTY="${BAR_EMPTY:-◇}"
SHOW_HEADER="${SHOW_HEADER:-true}"
SHOW_CPU_INFO="${SHOW_CPU_INFO:-true}"
SHOW_SYSTEM_INFO="${SHOW_SYSTEM_INFO:-true}"
SHOW_NETWORK="${SHOW_NETWORK:-true}"
SHOW_RESOURCES="${SHOW_RESOURCES:-true}"
SHOW_SWAP="${SHOW_SWAP:-true}"
SHOW_SERVICES="${SHOW_SERVICES:-true}"
SHOW_UPDATES="${SHOW_UPDATES:-true}"
PUBLIC_IP_TIMEOUT="${PUBLIC_IP_TIMEOUT:-1}"
SHOW_VPN="${SHOW_VPN:-true}"
MONITOR_SERVICES="${MONITOR_SERVICES:-ssh,docker,tailscaled}"

# --- Terminal Width & Colors ---
TERM_COLS=$(tput cols 2>/dev/null || echo 40)
[[ "$TERM_COLS" -lt 36 ]] && TERM_COLS=36
if [[ "$TERM_COLS" -gt 60 ]]; then
    LINE_WIDTH=52
else
    LINE_WIDTH=$((TERM_COLS - 2))
fi

# Color Palettes (ANSI 256 / 16 color compatible)
RST="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

case "$THEME" in
    green)
        C_PRI="\033[38;5;48m"
        C_SEC="\033[38;5;35m"
        C_ACC="\033[38;5;120m"
        ;;
    purple|magenta)
        C_PRI="\033[38;5;141m"
        C_SEC="\033[38;5;99m"
        C_ACC="\033[38;5;219m"
        ;;
    blue)
        C_PRI="\033[38;5;39m"
        C_SEC="\033[38;5;33m"
        C_ACC="\033[38;5;75m"
        ;;
    yellow|gold)
        C_PRI="\033[38;5;220m"
        C_SEC="\033[38;5;214m"
        C_ACC="\033[38;5;228m"
        ;;
    rainbow)
        C_PRI="\033[38;5;51m"
        C_SEC="\033[38;5;201m"
        C_ACC="\033[38;5;226m"
        ;;
    mono)
        C_PRI="\033[1;37m"
        C_SEC="\033[0;37m"
        C_ACC="\033[1;37m"
        ;;
    cyan|*)
        C_PRI="\033[38;5;51m"
        C_SEC="\033[38;5;45m"
        C_ACC="\033[38;5;123m"
        ;;
esac

# Status Colors
C_OK="\033[38;5;42m"      # Green
C_WARN="\033[38;5;214m"   # Yellow / Orange
C_CRIT="\033[38;5;196m"   # Red
C_GRAY="\033[38;5;242m"   # Muted Gray
C_WHITE="\033[38;5;255m"  # Crisp White
C_LABEL="\033[38;5;250m"  # Soft White

# Determine Progress Bar Width
if [[ "$BAR_WIDTH" == "auto" ]]; then
    if [[ "$TERM_COLS" -lt 55 ]]; then
        BAR_LEN=10
    else
        BAR_LEN=15
    fi
else
    BAR_LEN="$BAR_WIDTH"
fi

# UTF-8 Safe Repeat Helper
repeat_str() {
    local str="$1"
    local count="$2"
    local out=""
    for (( i=0; i<count; i++ )); do
        out+="$str"
    done
    printf "%s" "$out"
}

# Divider Line
draw_divider() {
    printf "${C_GRAY}%s${RST}\n" "$(repeat_str "─" "$LINE_WIDTH")"
}

# Progress Bar Generator
render_bar() {
    local percent=$1
    local length=${2:-$BAR_LEN}
    local filled_len=$(( percent * length / 100 ))
    local empty_len=$(( length - filled_len ))
    
    [[ $filled_len -gt $length ]] && filled_len=$length
    [[ $filled_len -lt 0 ]] && filled_len=0
    [[ $empty_len -lt 0 ]] && empty_len=0

    # Color threshold for bar
    local bar_color="$C_OK"
    if [[ $percent -ge 85 ]]; then
        bar_color="$C_CRIT"
    elif [[ $percent -ge 65 ]]; then
        bar_color="$C_WARN"
    fi

    local fill_chars=""
    local empty_chars=""
    [[ $filled_len -gt 0 ]] && fill_chars=$(repeat_str "$BAR_FILLED" "$filled_len")
    [[ $empty_len -gt 0 ]] && empty_chars=$(repeat_str "$BAR_EMPTY" "$empty_len")

    printf "${C_GRAY}[${bar_color}${fill_chars}${C_GRAY}${empty_chars}${C_GRAY}]${RST}"
}

# Mini 3-line ASCII Banner Renderer
print_banner() {
    local text="${BANNER_TEXT^^}" # Uppercase
    
    # Predefined optimized mini banners
    if [[ "$text" == "FATAH" ]]; then
        printf "${C_PRI}  ╔═╗╔═╗╔╦╗╔═╗╦ ╦\n"
        printf "${C_SEC}  ╠╣ ╠═╣ ║ ╠═╣╠═╣\n"
        printf "${C_ACC}  ╚  ╩ ╩ ╩ ╩ ╩╩ ╩\n"
    elif [[ "$text" == "LINUX" ]]; then
        printf "${C_PRI}  ╦  ╦╔╗╔╦ ╦═╗ ╦\n"
        printf "${C_SEC}  ║  ║║║║║ ║╔╩╦╝\n"
        printf "${C_ACC}  ╩═╝╩╝╚╝╚═╝╩ ╚═\n"
    elif [[ "$text" == "SERVER" ]]; then
        printf "${C_PRI}  ╔═╗╔═╗╦═╗╦  ╦╔═╗╦═╗\n"
        printf "${C_SEC}  ╚═╗║╣ ╠╦╝╚╗╔╝║╣ ╠╦╝\n"
        printf "${C_ACC}  ╚═╝╚═╝╩╚═ ╚╝ ╚═╝╩╚═\n"
    elif [[ "$text" == "DEBIAN" ]]; then
        printf "${C_PRI}  ╔╦╗╔═╗╔╗ ╦╔═╗╔╗╔\n"
        printf "${C_SEC}   ║║║╣ ╠╩╗║╠═╣║║║\n"
        printf "${C_ACC}  ═╩╝╚═╝╚═╝╩╩ ╩╝╚╝\n"
    elif [[ "$text" == "UBUNTU" ]]; then
        printf "${C_PRI}  ╦ ╦╔╗ ╦ ╦╔╗╔╔╦╗╦ ╦\n"
        printf "${C_SEC}  ║ ║╠╩╗║ ║║║║ ║ ║ ║\n"
        printf "${C_ACC}  ╚═╝╚═╝╚═╝╝╚╝ ╩ ╚═╝\n"
    else
        # Dynamic mini character fallback
        local line1="  "
        local line2="  "
        local line3="  "
        for (( i=0; i<${#text}; i++ )); do
            local char="${text:$i:1}"
            case "$char" in
                A) line1+="╔═╗ "; line2+="╠═╣ "; line3+="╩ ╩ " ;;
                B) line1+="╔╗  "; line2+="╠╩╗ "; line3+="╚═╝ " ;;
                C) line1+="╔═╗ "; line2+="║   "; line3+="╚═╝ " ;;
                D) line1+="╦═╗ "; line2+="║ ║ "; line3+="╩═╝ " ;;
                E) line1+="╔═╗ "; line2+="╠╣  "; line3+="╚═╝ " ;;
                F) line1+="╔═╗ "; line2+="╠╣  "; line3+="╚   " ;;
                G) line1+="╔═╗ "; line2+="║ ╦ "; line3+="╚═╝ " ;;
                H) line1+="╦ ╦ "; line2+="╠═╣ "; line3+="╩ ╩ " ;;
                I) line1+="╦ "; line2+="║ "; line3+="╩ " ;;
                J) line1+="  ╦ "; line2+="  ║ "; line3+="╚═╝ " ;;
                K) line1+="╦╔═ "; line2+="╠╩╗ "; line3+="╩ ╩ " ;;
                L) line1+="╦   "; line2+="║   "; line3+="╩═╝ " ;;
                M) line1+="╔╦╗ "; line2+="║║║ "; line3+="╩ ╩ " ;;
                N) line1+="╔╗╔ "; line2+="║║║ "; line3+="╝╚╝ " ;;
                O) line1+="╔═╗ "; line2+="║ ║ "; line3+="╚═╝ " ;;
                P) line1+="╔═╗ "; line2+="╠═╝ "; line3+="╩   " ;;
                Q) line1+="╔═╗ "; line2+="║ ║ "; line3+="╚═╝ " ;;
                R) line1+="╦═╗ "; line2+="╠╦╝ "; line3+="╩╚═ " ;;
                S) line1+="╔═╗ "; line2+="╚═╗ "; line3+="╚═╝ " ;;
                T) line1+="╔╦╗ "; line2+=" ║  "; line3+=" ╩  " ;;
                U) line1+="╦ ╦ "; line2+="║ ║ "; line3+="╚═╝ " ;;
                V) line1+="╦  ╦ "; line2+="╚╗╔╝ "; line3+=" ╚╝  " ;;
                W) line1+="╦ ╦ "; line2+="║║║ "; line3+="╚╩╝ " ;;
                X) line1+="═╗ ╔═ "; line2+=" ╔╩╦╝  "; line3+=" ╩ ╚═  " ;;
                Y) line1+="╦ ╦ "; line2+="╚╦╝ "; line3+=" ╩  " ;;
                Z) line1+="╔═╗ "; line2+=" ╔╝ "; line3+="╚═╝ " ;;
                0) line1+="╔═╗ "; line2+="║║║ "; line3+="╚═╝ " ;;
                1) line1+="╔╗  "; line2+=" ║  "; line3+="═╩═ " ;;
                2) line1+="╔═╗ "; line2+="╔═╝ "; line3+="╚═╝ " ;;
                3) line1+="═╗  "; line2+=" ═╣ "; line3+="═╝  " ;;
                4) line1+="╦ ╦ "; line2+="╚═╣ "; line3+="  ╩ " ;;
                5) line1+="╔═╗ "; line2+="╚═╗ "; line3+="╚═╝ " ;;
                6) line1+="╔═╗ "; line2+="╠═╗ "; line3+="╚═╝ " ;;
                7) line1+="╔═╗ "; line2+="  ║ "; line3+="  ╩ " ;;
                8) line1+="╔═╗ "; line2+="╠═╣ "; line3+="╚═╝ " ;;
                9) line1+="╔═╗ "; line2+="╚═╣ "; line3+="╚═╝ " ;;
                ' ') line1+="  "; line2+="  "; line3+="  " ;;
                *) line1+="$char "; line2+="$char "; line3+="$char " ;;
            esac
        done
        printf "${C_PRI}%s\n" "$line1"
        printf "${C_SEC}%s\n" "$line2"
        printf "${C_ACC}%s\n" "$line3"
    fi
}

# --- Gather System Info ---

# CPU Model & Core count
CPU_MODEL=""
CPU_CORES=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1)
if [[ -f /proc/cpuinfo ]]; then
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | awk -F: '{print $2}' | sed -e 's/(R)//g' -e 's/(TM)//g' -e 's/CPU //g' -e 's/Processor//g' | tr -s ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [[ -z "$CPU_MODEL" ]]; then
        CPU_MODEL=$(grep -m1 -i "^Hardware" /proc/cpuinfo | awk -F: '{print $2}' | tr -s ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    fi
    if [[ -z "$CPU_MODEL" ]]; then
        CPU_MODEL=$(grep -m1 -i "^Processor" /proc/cpuinfo | awk -F: '{print $2}' | tr -s ' ' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    fi
fi
if [[ -z "$CPU_MODEL" ]] && command -v getprop &>/dev/null; then
    CPU_MODEL=$(getprop ro.soc.model 2>/dev/null || getprop ro.product.board 2>/dev/null || echo "")
fi
[[ -z "$CPU_MODEL" || "$CPU_MODEL" == "unknown" ]] && CPU_MODEL="$(uname -p 2>/dev/null || uname -m)"
if [[ "$CPU_CORES" -gt 1 ]]; then
    CORE_STR="${CPU_CORES} Cores"
else
    CORE_STR="1 Core"
fi

# OS Info
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    OS_NAME="${PRETTY_NAME:-$NAME}"
elif [[ -f "${PREFIX:-}/etc/os-release" ]]; then
    # shellcheck source=/dev/null
    source "${PREFIX:-}/etc/os-release"
    OS_NAME="${PRETTY_NAME:-$NAME}"
else
    OS_NAME="$(uname -s)"
fi
if [[ -n "${TERMUX_VERSION:-}" || -d "/data/data/com.termux" ]] && [[ "$OS_NAME" == "Linux" || -z "$OS_NAME" ]]; then
    if [[ -n "${TERMUX_VERSION:-}" ]]; then
        OS_NAME="Termux v${TERMUX_VERSION}"
    else
        OS_NAME="Termux (Android)"
    fi
fi
KERNEL_VER="$(uname -r)"
ARCH="$(uname -m)"
HOSTNAME_STR="$(hostname)"

# Uptime
if [[ -f /proc/uptime ]]; then
    UP_SECS=$(cut -d. -f1 /proc/uptime)
    DAYS=$(( UP_SECS / 86400 ))
    HOURS=$(( (UP_SECS % 86400) / 3600 ))
    MINS=$(( (UP_SECS % 3600) / 60 ))
    
    UPTIME_STR=""
    [[ $DAYS -gt 0 ]] && UPTIME_STR="${DAYS}d "
    [[ $HOURS -gt 0 || $DAYS -gt 0 ]] && UPTIME_STR+="${HOURS}h "
    UPTIME_STR+="${MINS}m"
else
    UPTIME_STR="$(uptime -p 2>/dev/null | sed 's/up //')"
fi

# Active Sessions
USER_COUNT=$(who 2>/dev/null | wc -l | tr -d ' ')
[[ -z "$USER_COUNT" || "$USER_COUNT" == "0" ]] && USER_COUNT="1"

# --- Memory Calculation (/proc/meminfo) ---
MEM_TOTAL_KB=0
MEM_AVAIL_KB=0
SWAP_TOTAL_KB=0
SWAP_FREE_KB=0

if [[ -f /proc/meminfo ]]; then
    while IFS=':' read -r key val; do
        val_num=$(echo "$val" | awk '{print $1}')
        case "$key" in
            MemTotal) MEM_TOTAL_KB=$val_num ;;
            MemAvailable) MEM_AVAIL_KB=$val_num ;;
            MemFree) [[ $MEM_AVAIL_KB -eq 0 ]] && MEM_AVAIL_KB=$val_num ;;
            SwapTotal) SWAP_TOTAL_KB=$val_num ;;
            SwapFree) SWAP_FREE_KB=$val_num ;;
        esac
    done < /proc/meminfo
fi

format_bytes_mb() {
    local kb=$1
    if [[ $kb -ge 1048576 ]]; then
        awk "BEGIN {printf \"%.1fG\", $kb / 1048576}"
    else
        awk "BEGIN {printf \"%dM\", $kb / 1024}"
    fi
}

# RAM Formatted
MEM_USED_KB=$(( MEM_TOTAL_KB - MEM_AVAIL_KB ))
if [[ $MEM_TOTAL_KB -gt 0 ]]; then
    MEM_PERCENT=$(( (MEM_USED_KB * 100) / MEM_TOTAL_KB ))
else
    MEM_PERCENT=0
fi
MEM_USED_STR=$(format_bytes_mb "$MEM_USED_KB")
MEM_TOTAL_STR=$(format_bytes_mb "$MEM_TOTAL_KB")

# SWAP Formatted
SWAP_USED_KB=$(( SWAP_TOTAL_KB - SWAP_FREE_KB ))
if [[ $SWAP_TOTAL_KB -gt 0 ]]; then
    SWAP_PERCENT=$(( (SWAP_USED_KB * 100) / SWAP_TOTAL_KB ))
    SWAP_USED_STR=$(format_bytes_mb "$SWAP_USED_KB")
    SWAP_TOTAL_STR=$(format_bytes_mb "$SWAP_TOTAL_KB")
    SWAP_AVAILABLE=true
    if [[ $SWAP_USED_KB -gt 0 && $SWAP_PERCENT -eq 0 ]]; then
        SWAP_PERCENT_DISP="<1%"
    else
        SWAP_PERCENT_DISP="${SWAP_PERCENT}%"
    fi
else
    SWAP_PERCENT=0
    SWAP_USED_STR="0M"
    SWAP_TOTAL_STR="Off"
    SWAP_AVAILABLE=false
    SWAP_PERCENT_DISP="Off"
fi

# --- Disk Calculation (Root /) ---
DISK_INFO=$(df -h / 2>/dev/null | tail -1)
DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
DISK_PERCENT_STR=$(echo "$DISK_INFO" | awk '{print $5}' | tr -d '%')
DISK_PERCENT=${DISK_PERCENT_STR:-0}

# --- Network Calculation ---
DEFAULT_IFACE=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')
if [[ -n "$DEFAULT_IFACE" ]]; then
    LAN_IP=$(ip -4 addr show dev "$DEFAULT_IFACE" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
fi
[[ -z "$LAN_IP" ]] && LAN_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
[[ -z "$LAN_IP" ]] && LAN_IP="127.0.0.1"

# VPN IP (Tailscale, Wireguard, Tun)
VPN_INFO=""
if [[ "$SHOW_VPN" == "true" ]]; then
    if ip link show tailscale0 &>/dev/null; then
        TS_IP=$(ip -4 addr show dev tailscale0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
        [[ -n "$TS_IP" ]] && VPN_INFO="${TS_IP} (tailscale)"
    elif ip link show wg0 &>/dev/null; then
        WG_IP=$(ip -4 addr show dev wg0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
        [[ -n "$WG_IP" ]] && VPN_INFO="${WG_IP} (wireguard)"
    fi
fi

# Public IP (Cached for 1 hour or Fast Lookup)
PUBLIC_IP=""
if [[ "$PUBLIC_IP_TIMEOUT" -gt 0 ]]; then
    IP_CACHE="${TMPDIR:-/tmp}/.motd_public_ip"
    CACHE_VALID=false
    if [[ -f "$IP_CACHE" ]]; then
        CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$IP_CACHE" 2>/dev/null || echo 0) ))
        if [[ $CACHE_AGE -lt 3600 ]]; then
            PUBLIC_IP=$(cat "$IP_CACHE" 2>/dev/null)
            [[ -n "$PUBLIC_IP" ]] && CACHE_VALID=true
        fi
    fi
    
    if [[ "$CACHE_VALID" == "false" ]]; then
        PUBLIC_IP=$(curl -s --max-time "$PUBLIC_IP_TIMEOUT" https://icanhazip.com 2>/dev/null | tr -d '[:space:]')
        [[ -z "$PUBLIC_IP" ]] && PUBLIC_IP=$(curl -s --max-time "$PUBLIC_IP_TIMEOUT" https://ifconfig.me 2>/dev/null | tr -d '[:space:]')
        if [[ -n "$PUBLIC_IP" ]]; then
            mkdir -p "$(dirname "$IP_CACHE")" 2>/dev/null || true
            echo "$PUBLIC_IP" > "$IP_CACHE" 2>/dev/null || true
        fi
    fi
fi

# --- Services Status ---
SERVICE_STATUS_ITEMS=()
if [[ "$SHOW_SERVICES" == "true" && -n "$MONITOR_SERVICES" ]]; then
    IFS=',' read -ra SVCS <<< "$MONITOR_SERVICES"
    for svc in "${SVCS[@]}"; do
        svc_clean=$(echo "$svc" | tr -d ' ')
        [[ -z "$svc_clean" ]] && continue
        
        if systemctl is-active --quiet "$svc_clean" 2>/dev/null; then
            SERVICE_STATUS_ITEMS+=("${C_OK}●${RST} ${svc_clean^}")
        elif [[ "$svc_clean" == "docker" ]] && command -v docker &>/dev/null; then
            if docker info &>/dev/null; then
                CONTAINERS_RUNNING=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
                SERVICE_STATUS_ITEMS+=("${C_OK}●${RST} Docker (${CONTAINERS_RUNNING})")
            fi
        fi
    done
fi

# --- Package Updates ---
UPDATES_COUNT=0
if [[ "$SHOW_UPDATES" == "true" ]]; then
    if [[ -f /var/lib/update-notifier/updates-available ]]; then
        UPDATES_COUNT=$(grep -oE '[0-9]+ packages can be updated' /var/lib/update-notifier/updates-available 2>/dev/null | awk '{print $1}' || echo 0)
    elif [[ -f /var/lib/apt/periodic/update-notifier-needed ]]; then
        UPDATES_COUNT=$(cat /var/lib/apt/periodic/update-notifier-needed 2>/dev/null || echo 0)
    fi
fi


# ==============================================================================
# RENDER OUTPUT
# ==============================================================================
printf "\n"

# 1. Header & Banner
if [[ "$SHOW_HEADER" == "true" ]]; then
    print_banner
    printf "  ${C_LABEL}%s${RST} ${C_GRAY}•${RST} ${C_PRI}%s${RST}\n" "$HOSTNAME_STR" "$OS_NAME"
    draw_divider
fi

# 2. System & Network Info
if [[ "$SHOW_SYSTEM_INFO" == "true" || "$SHOW_NETWORK" == "true" ]]; then
    if [[ "$SHOW_CPU_INFO" == "true" && -n "$CPU_MODEL" ]]; then
        printf " ${C_PRI}✦${RST} ${C_LABEL}CPU     :${RST} %s ${C_GRAY}(%s)${RST}\n" "$CPU_MODEL" "$CORE_STR"
    fi
    printf " ${C_PRI}✦${RST} ${C_LABEL}Kernel  :${RST} %s (%s)\n" "$KERNEL_VER" "$ARCH"
    printf " ${C_PRI}✦${RST} ${C_LABEL}Uptime  :${RST} %s ${C_GRAY}|${RST} ${C_LABEL}User(s):${RST} %s\n" "$UPTIME_STR" "$USER_COUNT"
    
    if [[ "$SHOW_NETWORK" == "true" ]]; then
        if [[ -n "$DEFAULT_IFACE" ]]; then
            printf " ${C_PRI}✦${RST} ${C_LABEL}IP LAN  :${RST} %s ${C_GRAY}(%s)${RST}\n" "$LAN_IP" "$DEFAULT_IFACE"
        else
            printf " ${C_PRI}✦${RST} ${C_LABEL}IP LAN  :${RST} %s\n" "$LAN_IP"
        fi
        
        if [[ -n "$VPN_INFO" ]]; then
            printf " ${C_PRI}✦${RST} ${C_LABEL}IP VPN  :${RST} %s\n" "$VPN_INFO"
        fi
        
        if [[ -n "$PUBLIC_IP" ]]; then
            printf " ${C_PRI}✦${RST} ${C_LABEL}IP WAN  :${RST} %s\n" "$PUBLIC_IP"
        fi
    fi
    draw_divider
fi

# 3. Resources (RAM, SWAP, DISK)
if [[ "$SHOW_RESOURCES" == "true" ]]; then
    # RAM
    RAM_BAR=$(render_bar "$MEM_PERCENT")
    printf " ${C_LABEL}%-4s${RST} %s ${BOLD}%4s${RST}  %s / %s\n" "RAM" "$RAM_BAR" "${MEM_PERCENT}%" "$MEM_USED_STR" "$MEM_TOTAL_STR"
    
    # SWAP
    if [[ "$SHOW_SWAP" == "true" ]]; then
        if [[ "$SWAP_AVAILABLE" == "true" ]]; then
            SWAP_BAR=$(render_bar "$SWAP_PERCENT")
            printf " ${C_LABEL}%-4s${RST} %s ${BOLD}%4s${RST}  %s / %s\n" "SWAP" "$SWAP_BAR" "$SWAP_PERCENT_DISP" "$SWAP_USED_STR" "$SWAP_TOTAL_STR"
        else
            SWAP_BAR=$(render_bar 0)
            printf " ${C_LABEL}%-4s${RST} %s ${C_GRAY}%4s  None / Disabled${RST}\n" "SWAP" "$SWAP_BAR" "Off"
        fi
    fi
    
    # DISK
    DISK_BAR=$(render_bar "$DISK_PERCENT")
    printf " ${C_LABEL}%-4s${RST} %s ${BOLD}%4s${RST}  %s / %s\n" "DISK" "$DISK_BAR" "${DISK_PERCENT}%" "$DISK_USED" "$DISK_TOTAL"
    
    draw_divider
fi

# 4. Services & Updates
if [[ "$SHOW_SERVICES" == "true" && ${#SERVICE_STATUS_ITEMS[@]} -gt 0 ]] || [[ "$SHOW_UPDATES" == "true" ]]; then
    if [[ ${#SERVICE_STATUS_ITEMS[@]} -gt 0 ]]; then
        SERVICES_LINE=$(IFS='  '; echo "${SERVICE_STATUS_ITEMS[*]}")
        printf " ${C_PRI}✦${RST} ${C_LABEL}Status  :${RST} %b\n" "$SERVICES_LINE"
    fi
    
    if [[ "$SHOW_UPDATES" == "true" ]]; then
        if [[ "$UPDATES_COUNT" -gt 0 ]]; then
            printf " ${C_WARN}✦${RST} ${C_LABEL}Updates :${RST} ${C_WARN}%s package(s) upgradable${RST}\n" "$UPDATES_COUNT"
        else
            printf " ${C_OK}✦${RST} ${C_LABEL}Updates :${RST} ${C_OK}System is up to date${RST}\n"
        fi
    fi
    draw_divider
fi

printf "\n"
