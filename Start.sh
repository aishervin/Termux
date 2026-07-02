#!/bin/bash
# Exclusive ☬SHΞN™ made
# SHΞN TERMUX COLD STARTER

# --- Color Variables ---
ORANGE='\e[38;5;214m'
GRAY='\e[38;5;245m'
WHITE='\e[97m'
RESET='\e[0m'

# --- Initialization & Terminal Setup ---
# Hide cursor for a cleaner look and ensure it comes back on exit
tput civis
trap "tput cnorm; echo -e '\n${GRAY}Setup interrupted.${RESET}'; exit" INT TERM EXIT

clear
echo -e "${ORANGE}=========================================${RESET}"
echo -e "${WHITE}        SHΞN TERMUX COLD STARTER         ${RESET}"
echo -e "${ORANGE}=========================================${RESET}"
echo ""

# --- Storage Permission ---
echo -e "${GRAY}[*] Requesting Storage Access... Please allow on your screen.${RESET}"
termux-setup-storage
# Brief pause to allow the Android prompt to appear before the screen locks into the progress loop
sleep 3 

# --- Task Definition ---
# Arrays containing the commands and their corresponding display names
declare -a TASKS=(
    "pkg update -y"
    "pkg upgrade -y"
    "pkg install -y coreutils"
    "pkg install -y curl wget git nano"
    "pkg install -y python python-pip"
    "pkg install -y openssh nmap"
    "pkg install -y termux-api"
    "pkg install -y zip unzip tar"
)

declare -a TASK_NAMES=(
    "Updating Repositories"
    "Upgrading Packages"
    "Installing Core Environment"
    "Installing Essential Tools"
    "Setting up Python"
    "Installing Network Utilities"
    "Configuring Termux API"
    "Installing Archive Tools"
)

TOTAL_TASKS=${#TASKS[@]}
SUCCESS_LIST=()
FAIL_LIST=()

echo ""
echo ""

# --- Loading Animation & Execution ---
for i in "${!TASKS[@]}"; do
    # Calculate percentage
    let PERCENT="(i * 100) / TOTAL_TASKS"
    
    # Generate progress bar string (20 chars total)
    let FILLED="PERCENT / 5"
    let EMPTY="20 - FILLED"
    
    # Build the bar characters
    BAR=$(printf "%${FILLED}s" | tr ' ' '#')
    if [ $EMPTY -gt 0 ]; then
        SPACE=$(printf "%${EMPTY}s" | tr ' ' '-')
    else
        SPACE=""
    fi
    
    # Save cursor, move up, draw bar, draw detail, restore cursor
    tput sc
    tput cuu 2
    tput el
    echo -e "${ORANGE}[${WHITE}${BAR}${GRAY}${SPACE}${ORANGE}] ${WHITE}${PERCENT}%${RESET}"
    tput el
    echo -e "${GRAY}>>> ${TASK_NAMES[$i]}...${RESET}"
    tput rc
    
    # Execute the actual command silently
    eval "${TASKS[$i]}" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        SUCCESS_LIST+=("${TASK_NAMES[$i]}")
    else
        FAIL_LIST+=("${TASK_NAMES[$i]}")
    fi
done

# Force 100% completion display
tput sc
tput cuu 2
tput el
echo -e "${ORANGE}[${WHITE}####################${ORANGE}] ${WHITE}100%${RESET}"
tput el
echo -e "${GRAY}>>> Finalizing Setup...${RESET}"
tput rc
sleep 1

# --- Final Results Screen ---
clear
echo -e "${ORANGE}=========================================${RESET}"
echo -e "${WHITE}             SETUP COMPLETE              ${RESET}"
echo -e "${ORANGE}=========================================${RESET}"
echo -e "${WHITE}Successful Operations:${RESET}"

for item in "${SUCCESS_LIST[@]}"; do
    echo -e "${GRAY} [${ORANGE}✓${GRAY}] $item${RESET}"
done

if [ ${#FAIL_LIST[@]} -ne 0 ]; then
    echo ""
    echo -e "${WHITE}Failed Operations:${RESET}"
    for item in "${FAIL_LIST[@]}"; do
        echo -e "${GRAY} [${ORANGE}✗${GRAY}] $item${RESET}"
    done
fi

echo ""
echo -e "${GRAY}Environment is locked in and ready for deployment.${RESET}"
echo -e "${ORANGE}Exclusive ☬SHΞN™ made.${RESET}"
echo ""

# Restore cursor before exiting natively
tput cnorm
trap - INT TERM EXIT
