#!/data/data/com.termux/files/usr/bin/bash
# Hacker-style MOTD (static, no animation)
RESET="\033[0m"
BOLD="\033[1m"
G="\033[1;32m"
DG="\033[0;32m"
GRAY="\033[0;37m"
Y="\033[1;33m"

clear
echo -e "${G}===[ INTRUDER LOG ]===${RESET}"
echo -e "${DG}┌────────────────────────────────────────────────────┐${RESET}"
echo -e "${DG}│ ${BOLD}${G}Access:${RESET}${GRAY} Granted to $(whoami)@$(hostname)${RESET} ${DG}│${RESET}"
echo -e "${DG}│ ${BOLD}${G}Session:${RESET}${GRAY} $(date +'%Y-%m-%d %H:%M:%S')${RESET} ${DG}│${RESET}"
echo -e "${DG}└────────────────────────────────────────────────────┘${RESET}"
echo

echo -e "${G}[ OK ]${RESET} Kernel: $(uname -srmo)"
echo -e "${G}[ OK ]${RESET} Uptime: $(uptime -p 2>/dev/null || echo 'n/a')"

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
echo -e "${DG}>>> ${G}Stay sharp. Stay invisible.${RESET}"