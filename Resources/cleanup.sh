#!/bin/bash
# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Setup logging
LOGS_DIR="$HOME/cleanup_logs"
mkdir -p "$LOGS_DIR"
DELETION_LOG="$LOGS_DIR/deletions.log"
OPERATIONS_LOG="$LOGS_DIR/operations.log"
ERROR_LOG="$LOGS_DIR/errors.log"

# Also create a log file in the current working directory
CWD_LOG="$(pwd)/cleanup_$(date +%Y-%m-%d_%H-%M-%S).log"
touch "$CWD_LOG"
echo "System Cleanup Utility - Deletion Log" > "$CWD_LOG"
echo "Started: $(date)" >> "$CWD_LOG"
echo "User: $(whoami)" >> "$CWD_LOG"
echo "----------------------------------------" >> "$CWD_LOG"

# Timestamp function for logs
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Log functions
log_operation() {
    echo "$(timestamp) - $1" >> "$OPERATIONS_LOG"
    echo -e "${BLUE}${BOLD}INFO:${NC} $1"
}

log_error() {
    echo "$(timestamp) - ERROR: $1" >> "$ERROR_LOG"
    echo -e "${RED}${BOLD}ERROR:${NC} $1" >&2
}

log_deletion() {
    local item="$1"
    echo "$(timestamp) - DELETED: $item" >> "$DELETION_LOG"
    echo "DELETED: $item" >> "$CWD_LOG"
}

# Function to check if the script is run with sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}${BOLD}Notice:${NC} Some operations may require administrative privileges."
        echo -e "You can run again with 'sudo' for full functionality.\n"
    fi
}

# Function to get system information
get_system_info() {
    echo -e "\n=============== SYSTEM INFORMATION ===============" >> "$OPERATIONS_LOG"
    log_operation "Gathering system information..."
    
    OS_TYPE=$(uname -s)
    OS_VERSION=$(uname -r)
    HOSTNAME=$(hostname)
    CURRENT_USER=$(whoami)
    UPTIME=$(uptime)
    
    if [ "$OS_TYPE" = "Darwin" ]; then
        CPU_MODEL=$(sysctl -n machdep.cpu.brand_string)
        CPU_CORES=$(sysctl -n hw.physicalcpu)
        CPU_THREADS=$(sysctl -n hw.logicalcpu)
        RAM_TOTAL=$(sysctl -n hw.memsize | awk '{print $0/1073741824}')
        RAM_TOTAL=$(printf "%.2f GB" $RAM_TOTAL)
    else
        CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//')
        CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
        CPU_THREADS=$CPU_CORES
        RAM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    fi
    
    if [ "$OS_TYPE" = "Darwin" ]; then
        IP_ADDRESS=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -n 1)
        MAC_ADDRESS=$(ifconfig en0 | awk '/ether/{print $2}')
        WIRELESS_INTERFACE=$(networksetup -listallhardwareports | grep -A 1 "Wi-Fi" | grep "Device" | awk '{print $2}')
        GATEWAY=$(netstat -nr | grep default | head -n 1 | awk '{print $2}')
        NETWORK_NAME=$(networksetup -getairportnetwork en0 2>/dev/null | cut -d ":" -f 2 | sed 's/^[ \t]*//')
    else
        IP_ADDRESS=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1)
        MAC_ADDRESS=$(ip link show | grep -oP '(?<=link/ether\s)([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' | head -n 1)
        WIRELESS_INTERFACE=$(ip link show | grep -i wireless | cut -d: -f2 | awk '{print $1}' | head -n 1)
        GATEWAY=$(ip route | grep default | head -n 1 | awk '{print $3}')
        NETWORK_NAME=$(iwgetid -r 2>/dev/null)
    fi
    
    if [ "$OS_TYPE" = "Darwin" ]; then
        DISK_INFO=$(df -h / | tail -n 1)
        DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
        DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
        DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
        DISK_PERCENT=$(echo "$DISK_INFO" | awk '{print $5}')
    else
        DISK_INFO=$(df -h / | tail -n 1)
        DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
        DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
        DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
        DISK_PERCENT=$(echo "$DISK_INFO" | awk '{print $5}')
    fi
    
    echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                   SYSTEM INFORMATION                         ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${YELLOW}${BOLD}⚙️  HARDWARE INFORMATION${NC}"
    echo -e "${CYAN}${BOLD}CPU Model:${NC}        $CPU_MODEL"
    echo -e "${CYAN}${BOLD}CPU Cores:${NC}        $CPU_CORES physical cores, $CPU_THREADS threads"
    echo -e "${CYAN}${BOLD}RAM:${NC}              $RAM_TOTAL"
    
    echo -e "\n${YELLOW}${BOLD}💻 SYSTEM INFORMATION${NC}"
    echo -e "${CYAN}${BOLD}Operating System:${NC} $OS_TYPE $OS_VERSION"
    echo -e "${CYAN}${BOLD}Hostname:${NC}         $HOSTNAME"
    echo -e "${CYAN}${BOLD}Username:${NC}         $CURRENT_USER"
    echo -e "${CYAN}${BOLD}Date/Time:${NC}        $(date)"
    echo -e "${CYAN}${BOLD}Uptime:${NC}           $UPTIME"
    
    echo -e "\n${YELLOW}${BOLD}🌐 NETWORK INFORMATION${NC}"
    echo -e "${CYAN}${BOLD}IP Address:${NC}       $IP_ADDRESS"
    echo -e "${CYAN}${BOLD}Gateway:${NC}          $GATEWAY"
    echo -e "${CYAN}${BOLD}Network Name:${NC}     $NETWORK_NAME"
    echo -e "${CYAN}${BOLD}MAC Address:${NC}      $MAC_ADDRESS"
    echo -e "${CYAN}${BOLD}Interface:${NC}        $WIRELESS_INTERFACE"
    
    echo -e "\n${YELLOW}${BOLD}💾 DISK INFORMATION${NC}"
    echo -e "${CYAN}${BOLD}Total Disk Space:${NC} $DISK_TOTAL"
    echo -e "${CYAN}${BOLD}Used Disk Space:${NC}  $DISK_USED ($DISK_PERCENT)"
    echo -e "${CYAN}${BOLD}Available Space:${NC}  $DISK_AVAIL"
    
    local disk_percent_num=$(echo "$DISK_PERCENT" | tr -d '%')
    local bar_length=50
    local filled_length=$(($disk_percent_num * $bar_length / 100))
    local empty_length=$(($bar_length - $filled_length))
    
    disk_bar="["
    for ((i=0; i<$filled_length; i++)); do
        disk_bar+="█"
    done
    for ((i=0; i<$empty_length; i++)); do
        disk_bar+="░"
    done
    disk_bar+="] $DISK_PERCENT"
    
    if [ "$disk_percent_num" -gt 90 ]; then
        echo -e "${RED}${BOLD}Disk Usage:${NC}        $disk_bar ${RED}(CRITICAL)${NC}"
    elif [ "$disk_percent_num" -gt 75 ]; then
        echo -e "${YELLOW}${BOLD}Disk Usage:${NC}        $disk_bar ${YELLOW}(WARNING)${NC}"
    else
        echo -e "${GREEN}${BOLD}Disk Usage:${NC}        $disk_bar ${GREEN}(OK)${NC}"
    fi
    
    echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                END OF SYSTEM INFORMATION                     ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo "OS Type: $OS_TYPE $OS_VERSION" >> "$OPERATIONS_LOG"
    echo "Hostname: $HOSTNAME" >> "$OPERATIONS_LOG"
    echo "User: $CURRENT_USER" >> "$OPERATIONS_LOG"
    echo "CPU: $CPU_MODEL ($CPU_CORES cores, $CPU_THREADS threads)" >> "$OPERATIONS_LOG"
    echo "RAM: $RAM_TOTAL" >> "$OPERATIONS_LOG"
    echo "Date/Time: $(date)" >> "$OPERATIONS_LOG"
    echo "IP Address: $IP_ADDRESS" >> "$OPERATIONS_LOG"
    echo "Gateway: $GATEWAY" >> "$OPERATIONS_LOG"
    echo "Network: $NETWORK_NAME" >> "$OPERATIONS_LOG"
    echo "MAC Address: $MAC_ADDRESS" >> "$OPERATIONS_LOG"
    echo "Wireless Interface: $WIRELESS_INTERFACE" >> "$OPERATIONS_LOG"
    echo "Disk Space: Total=$DISK_TOTAL, Used=$DISK_USED ($DISK_PERCENT), Available=$DISK_AVAIL" >> "$OPERATIONS_LOG"
    echo "=========================================" >> "$OPERATIONS_LOG"
    
    echo "=== SYSTEM INFORMATION ===" >> "$CWD_LOG"
    echo "OS: $OS_TYPE $OS_VERSION" >> "$CWD_LOG"
    echo "Hostname: $HOSTNAME" >> "$CWD_LOG"
    echo "CPU: $CPU_MODEL" >> "$CWD_LOG"
    echo "RAM: $RAM_TOTAL" >> "$CWD_LOG"
    echo "IP: $IP_ADDRESS" >> "$CWD_LOG"
    echo "Gateway: $GATEWAY" >> "$CWD_LOG"
    echo "Disk: Total=$DISK_TOTAL, Available=$DISK_AVAIL" >> "$CWD_LOG"
    echo "=========================" >> "$CWD_LOG"
    
    read -p "Press Enter to continue..."
}

# ... (Other cleanup functions like safe_delete, analyze_disk_usage, clean_user_cache, etc. are assumed to be included here unchanged.)

# --------------------------------------------------------------------
# Command dispatcher: If an argument is provided, run the corresponding function
if [ "$1" != "" ]; then
    case "$1" in
        systeminfo) get_system_info; exit 0;;
        diskusage) analyze_disk_usage; exit 0;;
        usercache) clean_user_cache; exit 0;;
        tempfiles) clean_temp_files; exit 0;;
        trash) clean_trash; exit 0;;
        logs) clean_logs; exit 0;;
        timemachine) clean_time_machine_snapshots; exit 0;;
        macosdata) clean_macos_system_data; exit 0;;
        mailattachments) clean_mail_attachments; exit 0;;
        systemcaches) clean_system_caches; exit 0;;
        imessage) clean_imessage_attachments; exit 0;;
        quicklook) clean_quicklook_cache; exit 0;;
        spotlight) clean_spotlight_index; exit 0;;
        sysupdates) clean_system_update_files; exit 0;;
        *) echo "Unknown command: $1"; exit 1;;
    esac
fi

# --------------------------------------------------------------------
# If no argument is given, launch the interactive menu.
# (This portion of code remains as in your original interactive script)
