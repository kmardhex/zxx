#!/data/data/com.termux/files/usr/bin/bash
# ==========================================
#   Termux Neon MOTD by mDx_Dev (Revised)
# ==========================================

RESET="\033[0m"
BOLD="\033[1m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
WHITE="\033[0;37m"
PINK="\033[1;35m"

clear

# === Header dengan icon kecil merah, kuning, biru ===
echo -e "${RED}● ${YELLOW}● ${BLUE}●${RESET}   ${BOLD}${CYAN}Welcome to the Dor Tool — All Packages Included${RESET}"
echo -e "${PINK}──────────────────────────────────────────────${RESET}"

# === Info Singkat ===
echo -e "${YELLOW}- Diam Bukan Berarti Kalah,Tapi Sengaja Mengamati -${RESET}"
echo -e "${CYAN}Tanggal :${WHITE} $(date +'%A, %d %B %Y') ${CYAN}| Waktu :${WHITE} $(date +'%T')${RESET}"
echo -e "${CYAN}Kernel  :${WHITE} $(uname -srmo)${RESET}"

echo -e "${PINK}──────────────────────────────────────────────${RESET}"