#!/data/data/com.termux/files/usr/bin/bash
# Hacker-style MOTD (animated, short boot-like)
# --- Config (keep small so startup fast) ---
ANIM_SECS=1.2
TYPE_DELAY=0.004   # delay per char for typewriter

# --- Colors ---
RESET="\033[0m"
BOLD="\033[1m"
G="\033[1;32m"
DG="\033[0;32m"
GRAY="\033[0;37m"
Y="\033[1;33m"

# --- Helpers ---
type_write_fast(){
  local txt="$1"; local d="${2:-$TYPE_DELAY}"
  local i ch
  for ((i=0;i<${#txt};i++)); do
    ch="${txt:$i:1}"
    printf "%s" "$ch"
    sleep "$d" 2>/dev/null || :
  done
  printf "\n"
}

spinner_short(){
  local secs=${1:-1.0}
  local steps=12
  local delay=$(awk "BEGIN {printf \"%.4f\", $secs/$steps}")
  local chars=('|' '/' '-' '\')
  for ((i=0;i<steps;i++)); do
    printf "\r${G}booting${RESET} ${chars[i%4]} "
    sleep "$delay"
  done
  printf "\r${G}booting${RESET} ${G}✓${RESET}\n"
}

# --- Run ---
# If user set NO_MOTD_ANIM=1 skip animation (useful for fast startup)
if [ "${NO_MOTD_ANIM:-0}" != "1" ]; then
  clear
  spinner_short "$ANIM_SECS"
  printf "\n"
  printf "${G}"
  type_write_fast "  ███  Welcome To Cyber Indonesia ███" 0.006
  printf "${RESET}\n"
else
  clear
  printf "${G}===[ DIAM BUKAN BERARTI KALAH tapi SEDANG MENGAMATI ]===${RESET}\n"
fi

# --- Static info ---
echo -e "${DG}┌────────────────────────────────────────────────────┐${RESET}"
echo -e "${DG}│ ${BOLD}${G}Session:${RESET}${GRAY} $(date +'%Y-%m-%d %H:%M:%S')${RESET} ${DG}│${RESET}"
echo -e "${DG}└────────────────────────────────────────────────────┘${RESET}"
echo

echo -e "${RESET} Kernel: $(uname -srmo)"
echo -e "${RESET} Uptime: $(uptime -p 2>/dev/null || echo 'n/a')"

# IP (if available)
if command -v ip >/dev/null 2>&1; then
  ipaddr=$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)
  [ -n "$ipaddr" ] && echo -e "${G}[ NET ]${RESET} IP: ${GRAY}${ipaddr}${RESET}"
fi

# Battery (termux-battery-status)
if command -v termux-battery-status >/dev/null 2>&1; then
  bat=$(termux-battery-status | sed -n "s/.*percentage': \([0-9]*\).*/\1/p")
  echo -e "${G}[ PWR ]${RESET} Battery: ${GRAY}${bat:-n/a}%${RESET}"
fi

echo
echo -e "${Y}-- Security checks --${RESET}"
echo -e "${G}[AUTH]${RESET} OK    ${G}[FIREWALL]${RESET} ACTIVE    ${G}[INTRUSION]${RESET} 0 EVENTS"
echo
rnd=$(head -c 12 /dev/urandom 2>/dev/null | xxd -p 2>/dev/null | sed 's/\(..\)/\1:/g' | sed 's/:$//')
[ -z "$rnd" ] && rnd="$(date +%s | md5sum | cut -c1-12)"
echo -e "${GRAY}session-token: ${BOLD}${G}${rnd}${RESET}"
echo
echo -e "${DG}>>> ${G}Jangan Lupa Udud & Ngopi Mbah 😂${RESET}"
