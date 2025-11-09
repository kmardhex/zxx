#!/data/data/com.termux/files/usr/bin/bash
# ==============================
#  Script Installer XL (by mDx_Dev ) - diperbaiki
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
# Fungsi animasi titik progres (pesan, jumlah titik default 10)
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
        # gunakan pkg (termux) lalu fallback apt jika tidak ada
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

# pastikan direktori ada
mkdir -p "$INSTALL_DIR"

# download dengan pengecekan
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

# Beri executable hanya pada file yang diharapkan (daftar di bawah)
# Daftar file yang diperkirakan dibuat oleh zip
FILES=("otp" "rfs" "cekplp" "cplp" "dlt" "dor" "loop" "update" "plp.txt" "plp2.txt" "p" "r" "cpaket" "menu" "rdor" "rlop" "tgl")
# Beri executable pada file yang ada dan juga pada .sh yang baru saja diekstrak
for f in "${FILES[@]}"; do
    if [ -f "$INSTALL_DIR/$f" ]; then
        chmod +x "$INSTALL_DIR/$f" || true
    fi
done
# juga beri executable pada semua .sh di INSTALL_DIR yang diekstrak
find "$INSTALL_DIR" -maxdepth 1 -type f -name "*.sh" -exec chmod +x {} \; || true

printf "${GREEN}Ekstraksi selesai & permission diatur untuk file terkait!${RESET}\n\n"
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
    printf "   Semua file yang diharapkan ada di system!."
    printf "==============================================${RESET}\n\n"
else
    printf "\n${RED}Beberapa file tidak ditemukan setelah ekstraksi. Periksa konten ZIP atau URL.${RESET}\n"
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
    *)
        printf "${RED}Pilihan tidak valid. Menggunakan default: Dor default..🙏${RESET}\n"
        MOTD_URL="$MOTD_HACKER_URL"
        ;;
esac

# =====================================================
# DOWNLOAD & PASANG MOTD
printf "\n${CYAN}Mengunduh dan menginstal File Utama...${RESET}\n"
progress_bar "Menerapkan Script Dor By mDX"

if wget --timeout=30 -q -O "$MOTD_PATH" "$MOTD_URL"; then
    chmod +x "$MOTD_PATH" || true

    # Tambahkan baris pemanggil ke .bashrc dan .zshrc jika belum ada
    RC_LINE='[ -f ~/.motd.sh ] && bash ~/.motd.sh'
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            if ! grep -Fxq "$RC_LINE" "$rc"; then
                printf '\n%s\n' "$RC_LINE" >> "$rc"
            fi
        else
            # buat file baru dan tambahkan baris
            printf '%s\n' "$RC_LINE" > "$rc"
        fi
    done

    printf "${GREEN}Script Dor berhasil dipasang dan diaktifkan!${RESET}\n\n"
else
    printf "${RED}Gagal mengunduh Script dari %s${RESET}\n" "$MOTD_URL"
fi

# =====================================================
# BERSIHKAN CACHE (jika tersedia)
progress_bar "Membersihkan cache"
if command -v termux-setup-storage >/dev/null 2>&1; then
    # termux-setup-storage meminta izin; jalankan hanya untuk memicu permintaan izin
    termux-setup-storage >/dev/null 2>&1 || true
fi
if command -v apt >/dev/null 2>&1; then
    apt clean >/dev/null 2>&1 || true
elif command -v pkg >/dev/null 2>&1; then
    # pkg tidak selalu punya clean, tapi lakukan update sebagai placeholder
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

# =====================================================
# ANIMASI KELUAR TERMUX
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