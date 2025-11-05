#!/data/data/com.termux/files/usr/bin/bash
# =====================================================
#  Script Installer XL (by mDx_Dev + auto-download)
# =========================================

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
MOTD_URL="https://raw.githubusercontent.com/kmardhex/zxx/main/motd.sh"
MOTD_PATH="$HOME/.motd.sh"

# ==========================================
# Fungsi animasi titik progres
progress_bar() {
    local message=$1
    echo -ne "${YELLOW}${message}${RESET}"
    for i in {1..10}; do
        echo -ne "."
        sleep 0.3
    done
    echo -e " ${GREEN}✓${RESET}"
}

# ==========================================
# Bersihkan layar dan header
clear
echo -e "${CYAN}=============================================="
echo -e "         INSTALLER SCRIPT MyXL mDx"
echo -e "==============================================${RESET}\n"

# =========================================
# INSTALL PACKAGE WAJIB
# ==========================================
echo -e "${YELLOW}Melakukan instalasi paket wajib...${RESET}"
progress_bar "Menginstal php"
pkg install php -y > /dev/null 2>&1
progress_bar "Menginstal unzip"
pkg install unzip -y > /dev/null 2>&1
progress_bar "Menginstal wget"
pkg install wget -y > /dev/null 2>&1
echo -e "${GREEN}Semua dependensi telah diinstal!${RESET}\n"
sleep 0.5

# =========================================
# DOWNLOAD FILE TOOL
# =========================================
echo -e "\n${CYAN}Mengunduh file tool dari server...${RESET}"
progress_bar "Mengunduh file utama"
wget -q -O "$ZIP_PATH" "$ZIP_URL"

if [ ! -f "$ZIP_PATH" ]; then
    echo -e "${RED}Gagal mengunduh file ZIP! Periksa koneksi atau URL.${RESET}"
    exit 1
fi
echo -e "${GREEN}Unduhan selesai!${RESET}\n"
sleep 0.5

# =====================================================
# EKSTRAKSI FILE
# =====================================================
echo -e "${CYAN}Mengekstrak file...${RESET}"
progress_bar "Mengekstrak file"
unzip -o "$ZIP_PATH" -d "$INSTALL_DIR" > /dev/null 2>&1
rm -f "$ZIP_PATH"
chmod +x "$INSTALL_DIR"/*
echo -e "${GREEN}Ekstraksi selesai & permission diatur!${RESET}\n"
sleep 0.5

# =====================================================
# VERIFIKASI FILE
# =====================================================
FILES=("otp" "rfs" "cekplp" "cplp" "dlt" "dor" "loop" "update" "plp.txt" "plp2.txt")
MISSING=false
for FILE in "${FILES[@]}"; do
    if [ ! -f "$INSTALL_DIR/$FILE" ]; then
        echo -e "${RED}File hilang: $FILE${RESET}"
        MISSING=true
    fi
done

if [ "$MISSING" = false ]; then
    echo -e "\n${GREEN}=============================================="
    echo -e "       Instalasi Berhasil Diselesaikan!"
    echo -e "   Semua file sudah diatur permission-nya"
    echo -e "==============================================${RESET}\n"
else
    echo -e "\n${RED}Beberapa file tidak ditemukan setelah ekstraksi.${RESET}"
fi

# =====================================================
# DOWNLOAD & PASANG MOTD DARI GITHUB
# =====================================================
echo -e "${CYAN}Mengunduh dan menginstal bypass OTP...${RESET}"
progress_bar "Menerapkan Script DOR"
wget -q -O "$MOTD_PATH" "$MOTD_URL"

if [ ! -f "$MOTD_PATH" ]; then
    echo -e "${RED}Gagal mengunduh Script dari $MOTD_URL${RESET}"
else
    chmod +x "$MOTD_PATH"
    # Tambah ke bashrc / zshrc
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            grep -q 'bash ~/.motd.sh' "$rc" || echo '[ -f ~/.motd.sh ] && bash ~/.motd.sh' >> "$rc"
        fi
    done
    echo -e "${GREEN}Semua Script berhasil dipasang!${RESET}\n"
fi

# =====================================================
# BERSIHKAN CACHE
# =====================================================
progress_bar "Membersihkan cache"
termux-setup-storage > /dev/null 2>&1
apt clean > /dev/null 2>&1
sleep 0.5

# =====================================================
# PESAN PENUTUP
# =====================================================
echo -e "\n${GREEN}=============================================="
echo -e " Terimakasih telah menggunakan installer"
echo -e "      dari ${CYAN}mDx_Dev${GREEN} + MOTD otomatis!"
echo -e " Ketik ${YELLOW}menu${GREEN} untuk memulai!"
echo -e "==============================================${RESET}\n"

# =====================================================
# ANIMASI KELUAR TERMUX
# =====================================================
sleep 1
echo -e "${YELLOW}Membersihkan sesi dan keluar dari Termux...${RESET}"
sleep 1
for i in 3 2 1; do
    echo -ne "${CYAN}Menutup Termux dalam ${i}...\r${RESET}"
    sleep 1
done
clear
echo -e "${GREEN}Sampai jumpa!.. Selamat menggunakan tool dari kami..!${RESET}"
sleep 1
exit