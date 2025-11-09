#!/data/data/com.termux/files/usr/bin/bash
# ==============================
#  Script Installer XL (by mDx_Dev) + Sistem Ijin + Notif WA + Animasi
set -euo pipefail

# Warna
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"

# Lokasi & URL
INSTALL_DIR="/data/data/com.termux/files/usr/bin"
ZIP_URL="https://github.com/kmardhex/zxx/raw/main/x.zip"
ZIP_PATH="$INSTALL_DIR/mdx.zip"
MOTD_HACKER_URL="https://raw.githubusercontent.com/kmardhex/zxx/main/motd_hacker.sh"
MOTD_STATIC_URL="https://raw.githubusercontent.com/kmardhex/zxx/main/motd_static.sh"
MOTD_PATH="$HOME/.motd.sh"

# URL file ijin
IJIN_URL="https://raw.githubusercontent.com/kmardhex/anu/main/ijin.conf"
IJIN_CACHE="$HOME/.ijin.conf"

# =====================================================
# Animasi titik progres
progress_bar() {
    local message=${1:-"Working"}
    local dots=${2:-10}
    printf "${YELLOW}%s${RESET}" "$message"
    for _ in $(seq 1 "$dots"); do
        printf "."
        sleep 0.15
    done
    printf " ${GREEN}✓${RESET}\n"
}

# Efek loading teks berjalan
type_effect() {
    local text="$1"
    local delay="${2:-0.03}"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    printf "\n"
}

# =====================================================
# Header tampilan
clear
printf "${CYAN}==============================================\n"
printf "         ${BOLD}INSTALLER SCRIPT MyXL mDx${RESET}\n"
printf "${CYAN}==============================================${RESET}\n\n"

# =====================================================
# Normalisasi nomor (hapus semua selain angka)
normalise_number() {
    if [ $# -gt 0 ]; then
        echo "$1" | tr -cd '[:digit:]'
    else
        tr -cd '[:digit:]'
    fi
}

# =====================================================
# CEK IJIN INSTALASI
type_effect "${CYAN}🔐  Memulai verifikasi ijin instalasi...${RESET}" 0.03
sleep 0.5
read -r -p "Masukkan nomor handphone Anda (contoh: 0812..., 62812..., atau +62812...): " INSTALLER_NO_RAW

INSTALLER_NO=$(normalise_number "$INSTALLER_NO_RAW")

if [ -z "$INSTALLER_NO" ]; then
    printf "${RED}Nomor tidak valid. Batalkan instalasi.${RESET}\n"
    exit 1
fi

# Efek memeriksa izin
printf "\n${YELLOW}"
for msg in "Menghubungi server verifikasi" "Memeriksa data izin" "Memvalidasi nomor Anda"; do
    printf "%s" "$msg"
    for _ in $(seq 1 5); do
        printf "."
        sleep 0.2
    done
    printf "\r\033[K"
done
printf "${RESET}"

progress_bar "Memuat daftar ijin"

# Unduh file ijin.conf
if wget --timeout=30 -q -O "$IJIN_CACHE" "$IJIN_URL"; then
    :
else
    if [ -f "$IJIN_CACHE" ]; then
        printf "${YELLOW}Tidak dapat menghubungi server, menggunakan cache lokal.${RESET}\n"
    else
        printf "${RED}Gagal memuat daftar ijin. Instalasi dibatalkan.${RESET}\n"
        exit 1
    fi
fi

# Cek nomor di daftar
FOUND=false
while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    NL=$(echo "$line" | normalise_number)
    [ -z "$NL" ] && continue
    if [ "$NL" = "$INSTALLER_NO" ]; then
        FOUND=true
        break
    fi
done < "$IJIN_CACHE"

if [ "$FOUND" != true ]; then
    clear
    printf "\n${RED}======================================================${RESET}\n"
    type_effect "${RED}❌ Maaf, script ini bukan untuk umum.${RESET}" 0.04
    sleep 0.5
    type_effect "${YELLOW}Nomor Anda (${INSTALLER_NO_RAW}) belum terdaftar dalam daftar ijin.${RESET}" 0.03
    sleep 0.7
    printf "\n"
    type_effect "${CYAN}Silakan hubungi nomor WhatsApp berikut untuk mendapatkan:${RESET}" 0.03
    sleep 0.4
    type_effect "${GREEN}👉 Ijin khusus & akses premium dari script ini.${RESET}" 0.04
    sleep 0.5
    printf "\n${YELLOW}${BOLD}WhatsApp: 081916333862${RESET}\n"
    printf "${RED}======================================================${RESET}\n\n"
    sleep 2
    exit 1
fi

printf "\n${GREEN}✅ Nomor Anda terverifikasi — ijin ditemukan.\n"
type_effect "${CYAN}Lanjut ke proses instalasi...${RESET}" 0.04
sleep 0.5

# =====================================================
# FUNGSI: install paket bila belum ada
install_if_missing() {
    local pkgname=$1
    if ! command -v "$pkgname" >/dev/null 2>&1; then
        progress_bar "Menginstal $pkgname"
        if command -v pkg >/dev/null 2>&1; then
            pkg install "$pkgname" -y >/dev/null 2>&1
        else
            apt-get update >/dev/null 2>&1 || true
            apt-get install "$pkgname" -y >/dev/null 2>&1
        fi
    else
        progress_bar "$pkgname sudah terpasang"
    fi
}

# =====================================================
# INSTALL DEPENDENSI
printf "\n${YELLOW}Melakukan instalasi paket wajib...${RESET}\n"
install_if_missing php
install_if_missing unzip
install_if_missing wget
printf "${GREEN}Semua dependensi selesai.\n\n${RESET}"

# =====================================================
# DOWNLOAD TOOL
printf "${CYAN}Mengunduh file tool dari server...${RESET}\n"
progress_bar "Mengunduh file utama"
mkdir -p "$INSTALL_DIR"

if wget --timeout=30 -q -O "$ZIP_PATH" "$ZIP_URL"; then
    printf "${GREEN}Unduhan selesai..!\n${RESET}\n"
else
    printf "${RED}Gagal mengunduh file ZIP.${RESET}\n"
    exit 1
fi

# =====================================================
# EKSTRAKSI FILE
printf "${CYAN}Mengekstrak file...${RESET}\n"
progress_bar "Mengekstrak file"
if unzip -o "$ZIP_PATH" -d "$INSTALL_DIR" >/dev/null 2>&1; then
    rm -f "$ZIP_PATH"
else
    printf "${RED}Gagal mengekstrak file.${RESET}\n"
    exit 1
fi

FILES=("otp" "rfs" "cekplp" "cplp" "dlt" "dor" "loop" "update" "plp.txt" "plp2.txt" "p" "r" "cpaket" "menu" "rdor" "rlop" "tgl")
for f in "${FILES[@]}"; do
    [ -f "$INSTALL_DIR/$f" ] && chmod +x "$INSTALL_DIR/$f"
done
find "$INSTALL_DIR" -maxdepth 1 -type f -name "*.sh" -exec chmod +x {} \; || true

printf "${GREEN}Ekstraksi selesai dan permission sudah diatur.${RESET}\n\n"

# =====================================================
# PILIH MOTD
printf "${CYAN}Pilih Menu Script Dor Utama :${RESET}\n"
printf "${YELLOW}[1]${RESET} Script Dor Manual By mDx\n"
printf "${YELLOW}[2]${RESET} Script Dor Auto Update By mDx\n\n"
read -r -p "Masukkan pilihan (1/2): " choice
case "$choice" in
    1) MOTD_URL="$MOTD_HACKER_URL" ;;
    2) MOTD_URL="$MOTD_STATIC_URL" ;;
    *) MOTD_URL="$MOTD_HACKER_URL" ;;
esac

# =====================================================
# PASANG MOTD
printf "\n${CYAN}Menginstal File Utama...${RESET}\n"
progress_bar "Menerapkan Script Dor"
if wget --timeout=30 -q -O "$MOTD_PATH" "$MOTD_URL"; then
    chmod +x "$MOTD_PATH"
    RC_LINE='[ -f ~/.motd.sh ] && bash ~/.motd.sh'
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            grep -Fxq "$RC_LINE" "$rc" || printf '\n%s\n' "$RC_LINE" >> "$rc"
        else
            printf '%s\n' "$RC_LINE" > "$rc"
        fi
    done
    printf "${GREEN}Script Dor berhasil dipasang dan diaktifkan!${RESET}\n\n"
else
    printf "${RED}Gagal mengunduh Script Dor.${RESET}\n"
fi

# =====================================================
# PESAN PENUTUP
printf "\n${GREEN}==============================================\n"
printf " Terimakasih telah menggunakan installer\n"
printf "      dari ${CYAN}mDx_Dev${GREEN} + Jangan Bar-Bar\n"
printf " Ketik ${YELLOW}menu${GREEN} untuk memulai!\n"
printf "==============================================${RESET}\n\n"

sleep 1
printf "${YELLOW}Membersihkan sesi...${RESET}\n"
for i in 3 2 1; do
    printf "${CYAN}Menutup Termux dalam %s...\r${RESET}" "$i"
    sleep 1
done
clear
printf "${GREEN}Sampai jumpa!..Mbah 😁..!${RESET}\n"
sleep 1
exit 0