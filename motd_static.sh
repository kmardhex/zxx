#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#   Termux Neon MOTD by mDx_Dev
# ==========================================

RESET="\033[0m"
BOLD="\033[1m"
PINK="\033[1;35m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
WHITE="\033[0;37m"

clear
echo -e "${PINK}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${PINK}║${RESET} ${BOLD}${CYAN}  ___         _                         _   ${RESET}${PINK}║${RESET}"
echo -e "${PINK}║${RESET} ${BOLD}${CYAN} / _ \\ _   _ | |_  ___  _ __   ___  ___| |_ ${RESET}${PINK}║${RESET}"
echo -e "${PINK}║${RESET} ${BOLD}${CYAN}| | | | | | || __|/ _ \\| '_ \\ / _ \\/ __| __|${RESET}${PINK}║${RESET}"
echo -e "${PINK}║${RESET} ${BOLD}${CYAN}| |_| | |_| || |_|  __/| | | |  __/\\__ \\ |_ ${RESET}${PINK}║${RESET}"
echo -e "${PINK}║${RESET} ${BOLD}${CYAN} \\__\\_\\__,_| \\__|\\___||_| |_|\\___||___/\\__|${RESET}${PINK}║${RESET}"
echo -e "${PINK}╚══════════════════════════════════════════════╝${RESET}"

echo -e "$${YELLOW}- Welcome To Cyber Indonesia ${RESET}"
echo -e "${CYAN} Tanggal:${WHITE} $(date +'%A, %d %B %Y') ${CYAN}| Waktu:${WHITE} $(date +'%T')${RESET}"
echo -e "${CYAN} Kernel:${WHITE} $(uname -srmo)${RESET}"

echo -e "${PINK}────────────────────────────────────────────────────${RESET}"