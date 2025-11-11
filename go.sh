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
# lokasi tambahan yang akan dicek jika wget gagal
POSSIBLE_LOCAL=(
    "./ijin.conf"
    "$HOME/ijin.conf"
    "$INSTALL_DIR/ijin.conf"
    "/data/data/com.termux/files/home/ijin.conf"
)

printf "${CYAN}==============================================\n"
printf "           VERIFIKASI IJIN INSTALASI\n"
printf "==============================================${RESET}\n\n"

# Minta nomor HP dari user
read -p "Masukkan nomor WhatsApp Anda (contoh: 0812xxxxxx): " phone

# Normalisasi nomor (hapus semua karakter non-digit)
normalized=$(echo "$phone" | tr -cd '0-9')

# Function: buat file ijin ter-normalisasi (hanya digit per baris)
normalize_ijin_file() {
    local src=$1
    local dst=$2
    # Ambil setiap baris, keluarkan digit saja, hapus baris kosong, lalu unikkan
    awk '{print}' "$src" | sed 's/[^0-9]//g' | sed '/^$/d' | awk '!seen[$0]++' > "$dst"
}

# Download atau cari file ijin
printf "${YELLOW}Memeriksa daftar ijin di server...${RESET}\n"
DOWNLOAD_OK=false
if wget -q -O "$IJIN_LOCAL" "$IJIN_URL"; then
    printf "${GREEN}Daftar ijin berhasil diunduh dari server.${RESET}\n"
    DOWNLOAD_OK=true
else
    printf "${RED}Gagal mengunduh daftar ijin dari server.${RESET}\n"
    printf "${YELLOW}Mencari daftar ijin lokal pada lokasi umum...${RESET}\n"
    # coba cari file lokal pada lokasi-lokasi yang mungkin
    for p in "${POSSIBLE_LOCAL[@]}"; do
        if [ -f "$p" ]; then
            cp -f "$p" "$IJIN_LOCAL"
            printf "${GREEN}Menggunakan file ijin lokal: %s${RESET}\n" "$p"
            DOWNLOAD_OK=true
            break
        fi
    done
fi

if [ "$DOWNLOAD_OK" = false ]; then
    printf "${YELLOW}Tidak ditemukan daftar ijin (server & lokal). Proses akan tetap mencoba, tapi kemungkinan gagal jika file ijin memang diperlukan.${RESET}\n"
    # buat file kosong agar skrip tidak error saat grep (tapi akan dianggap tidak terdaftar)
    : > "$IJIN_LOCAL"
fi

# Normalisasi isi file ijin ke file sementara
IJIN_NORM="${IJIN_LOCAL}.norm"
normalize_ijin_file "$IJIN_LOCAL" "$IJIN_NORM"

# Siapkan varian nomor yang akan dicari:
#  - angka apa adanya (misal 081234...)
#  - jika mulai dengan 0 -> ubah ke 62... (hapus 0, tambah 62)
#  - jika mulai dengan 62 -> ubah ke 0... (ganti 62 -> 0)
#  - juga cek versi tanpa leading zero dan tanpa country code
variants=()
variants+=("$normalized")

if [[ "$normalized" =~ ^0 ]]; then
    no0="${normalized#0}"         # hapus leading 0
    variants+=("62${no0}")       # 62...
    variants+=("${no0}")         # tanpa 0
elif [[ "$normalized" =~ ^62 ]]; then
    after62="${normalized#62}"
    variants+=("0${after62}")    # 0...
    variants+=("${after62}")     # tanpa 62
else
    # jika dimasukkan misal 812345..., juga coba tambahkan 0 dan 62
    variants+=("0${normalized}")
    variants+=("62${normalized}")
fi

# Pastikan unikkan variants
uniq_variants=($(printf "%s\n" "${variants[@]}" | awk '!seen[$0]++'))

# Cek apakah salah satu varian ada di ijin yang sudah dinormalisasi
FOUND=false
for v in "${uniq_variants[@]}"; do
    # pastikan v bukan string kosong
    if [ -z "$v" ]; then
        continue
    fi
    if grep -xqF "$v" "$IJIN_NORM" 2>/dev/null; then
        FOUND=true
        MATCH="$v"
        break
    fi
done

if [ "$FOUND" = true ]; then
    printf "\n${GREEN}✅ Nomor Anda terdaftar (cocok: %s)! Instalasi dilanjutkan.${RESET}\n\n" "$MATCH"
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

FILES=("otp" "rfs" "cekplp" "cplp" "dlt" "dor" "loop" "update" "plp.txt" "plp2.txt" "r" "cpaket" "menu" "rdor" "rlop" "tgl" "sk" "bsc" "rcplp" "xlsatu")
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