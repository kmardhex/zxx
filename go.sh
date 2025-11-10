#!/data/data/com.termux/files/usr/bin/bash
# ==============================
#  Script Installer XL (by mDx_Dev )
set -euo pipefail

# Warna
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Lokasi & URL
INSTALL_DIR="/data/data/com.termux/files/usr/bin"
ZIP_URL="https://github.com/kmardhex/zxx/raw/main/x.zip"
ZIP_PATH="$INSTALL_DIR/mdx.zip"
MOTD_HACKER_URL="https://raw.githubusercontent.com/kmardhex/zxx/main/motd_hacker.sh"
MOTD_STATIC_URL="https://raw.githubusercontent.com/kmardhex/zxx/main/motd_static.sh"
MOTD_PATH="$HOME/.motd.sh"

# =====================================================
# VERIFIKASI IJIN INSTALASI
IJIN_URL="https://raw.githubusercontent.com/kmardhex/anu/main/ijin.conf"
IJIN_LOCAL="/data/data/com.termux/files/usr/tmp_ijin.conf"

printf "${CYAN}==============================================\n"
printf "           VERIFIKASI IJIN INSTALASI\n"
printf "==============================================${RESET}\n\n"

# Minta nomor HP dari user
read -p "Masukkan nomor WhatsApp Anda (contoh: 0812xxxxxx): " phone

# Normalisasi nomor (hapus semua karakter non-digit)
normalized=$(echo "$phone" | tr -cd '0-9')

# Download daftar ijin
printf "${YELLOW}Memeriksa daftar ijin di server...${RESET}\n"
if wget -q -O "$IJIN_LOCAL" "$IJIN_URL"; then
    printf "${GREEN}Daftar ijin berhasil diunduh.${RESET}\n"
else
    printf "${RED}Gagal mengunduh daftar ijin dari server.${RESET}\n"
    printf "${YELLOW}Mencoba memeriksa daftar ijin lokal (jika ada)...${RESET}\n"
fi

# Cek apakah nomor ada di daftar
if grep -q "$normalized" "$IJIN_LOCAL" 2>/dev/null; then
    printf "\n${GREEN}✅ Nomor Anda terdaftar! Instalasi dilanjutkan.${RESET}\n\n"
else
    # Jika nomor tidak ditemukan, tampilkan pesan berwarna dan keluar
    clear
    printf "\033[1;31m==============================================\033[0m\n"
    printf "\033[1;31m❌ Maaf, script ini bukan untuk umum.\033[0m\n"
    printf "\033[1;33mNomor Anda (\033[1;37m%s\033[1;33m) belum terdaftar dalam daftar ijin.\033[0m\n" "$phone"
    printf "\033[1;31m==============================================\033[0m\n\n"
    printf "\033[1;36mSilakan hubungi nomor WhatsApp berikut untuk mendapatkan:\033[0m\n"
    printf "\033[1;32m👉 Ijin khusus & akses premium dari script ini.\033[0m\n\n"
    printf "\033[1;33mWhatsApp:\033[0m \033[1;37m081916333862\033[0m\n"
    printf "\033[1;31m==============================================\033[0m\n\n"
    exit 1
fi

# =====================================================
# Fungsi animasi titik progres
progress_bar() {
    local message=${1:-"Working"}
    local dots=${2:-10}
    printf "${YELLOW}%s${RESET}" "$message"
    for _ in $(seq 1 "$dots"); do
        printf "."
        sleep 0.18
    done
    printf " ${GREEN}✓${RESET}\n"
}

# =====================================================
# Header tampilan
clear
printf "${CYAN}==============================================\n"
printf "         INSTALLER SCRIPT MyXL mDx\n"
printf "==============================================${RESET}\n\n"

# =====================================================
# FUNSI BANTU: install paket jika belum ada
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
# INSTALL PACKAGE WAJIB
printf "${YELLOW}Melakukan instalasi paket wajib...${RESET}\n"
install_if_missing php
install_if_missing unzip
install_if_missing wget
printf "${GREEN}Semua dependensi: selesai.\n\n${RESET}"
sleep 0.4

# =====================================================
# DOWNLOAD FILE TOOL
printf "\n${CYAN}Mengunduh file tool dari server...${RESET}\n"
progress_bar "Mengunduh file utama"

mkdir -p "$INSTALL_DIR"
if wget --timeout=30 -q -O "$ZIP_PATH" "$ZIP_URL"; then
    printf "${GREEN}Unduhan selesai..!\n\n" "$ZIP_PATH"
else
    printf "${RED}Gagal mengunduh file ZIP dari: %s${RESET}\n" "$ZIP_URL"
    exit 1
fi
sleep 0.3

# =====================================================
# EKSTRAKSI FILE
printf "${CYAN}Mengekstrak file...${RESET}\n"
progress_bar "Mengekstrak file"
if unzip -o "$ZIP_PATH" -d "$INSTALL_DIR" >/dev/null 2>&1; then
    rm -f "$ZIP_PATH"
else
    printf "${RED}Gagal mengekstrak %s${RESET}\n" "$ZIP_PATH"
    exit 1
fi

FILES=("otp" "rfs" "cekplp" "cplp" "dlt" "dor" "loop" "update" "plp.txt" "plp2.txt" "p" "r" "cpaket" "menu" "rdor" "rlop" "tgl" "sk")
for f in "${FILES[@]}"; do
    if [ -f "$INSTALL_DIR/$f" ]; then
        chmod +x "$INSTALL_DIR/$f" || true
    fi
done
find "$INSTALL_DIR" -maxdepth 1 -type f -name "*.sh" -exec chmod +x {} \; || true

printf "${GREEN}Ekstraksi selesai & permission diatur!${RESET}\n\n"
sleep 0.4

# =====================================================
# VERIFIKASI FILE
MISSING=false
for FILE in "${FILES[@]}"; do
    if [ ! -e "$INSTALL_DIR/$FILE" ]; then
        printf "${RED}File hilang: %s${RESET}\n" "$FILE"
        MISSING=true
    fi
done

if [ "$MISSING" = false ]; then
    printf "\n${GREEN}==============================================\n"
    printf "       Instalasi Berhasil Diselesaikan!\n"
    printf "   Semua file yang diharapkan ada di system!\n"
    printf "==============================================${RESET}\n\n"
else
    printf "\n${RED}Beberapa file tidak ditemukan setelah ekstraksi.${RESET}\n"
fi

# =====================================================
# PILIH TAMPILAN MOTD
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
# DOWNLOAD & PASANG MOTD
printf "\n${CYAN}Mengunduh dan menginstal File Utama...${RESET}\n"
progress_bar "Menerapkan Script Dor By mDX"

if wget --timeout=30 -q -O "$MOTD_PATH" "$MOTD_URL"; then
    chmod +x "$MOTD_PATH" || true
    RC_LINE='[ -f ~/.motd.sh ] && bash ~/.motd.sh'
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            if ! grep -Fxq "$RC_LINE" "$rc"; then
                printf '\n%s\n' "$RC_LINE" >> "$rc"
            fi
        else
            printf '%s\n' "$RC_LINE" > "$rc"
        fi
    done
    printf "${GREEN}Script Dor berhasil dipasang dan diaktifkan!${RESET}\n\n"
else
    printf "${RED}Gagal mengunduh Script dari %s${RESET}\n" "$MOTD_URL"
fi

# =====================================================
# BERSIHKAN CACHE
progress_bar "Membersihkan cache"
if command -v termux-setup-storage >/dev/null 2>&1; then
    termux-setup-storage >/dev/null 2>&1 || true
fi
if command -v apt >/dev/null 2>&1; then
    apt clean >/dev/null 2>&1 || true
elif command -v pkg >/dev/null 2>&1; then
    pkg update -y >/dev/null 2>&1 || true
fi
sleep 0.4

# =====================================================
# PESAN PENUTUP
printf "\n${GREEN}==============================================\n"
printf " Terimakasih telah menggunakan installer\n"
printf "      dari ${CYAN}mDx_Dev${GREEN} + Jangan Bar-Bar\n"
printf " Ketik ${YELLOW}menu${GREEN} untuk memulai!\n"
printf "==============================================${RESET}\n\n"

sleep 1
printf "${YELLOW}Membersihkan sesi...${RESET}\n"
sleep 1
for i in 3 2 1; do
    printf "${CYAN}Menutup Termux dalam %s...\r${RESET}" "$i"
    sleep 1
done
clear
printf "${GREEN}Sampai jumpa!..Mbah 😁..!${RESET}\n"
sleep 1
exit 0