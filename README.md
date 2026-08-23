<div align="center">

# 📱 simple-mobile-motd

**A lightweight, responsive, and mobile-friendly Message of the Day (MOTD) for Linux servers & Termux (Android).**

[![Shell Script](https://img.shields.io/badge/Language-Bash%205%2B-blue.svg?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform: Linux & Termux](https://img.shields.io/badge/Platform-Linux%20%7C%20Termux-brightgreen.svg?style=flat-square)](https://github.com/fatahilah-mr/simple-mobile-motd)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero%20(Pure%20Bash)-orange.svg?style=flat-square)](https://github.com/fatahilah-mr/simple-mobile-motd)

</div>

---

## ✨ Overview

**`simple-mobile-motd`** dirancang khusus untuk administrator server dan developer yang sering mengakses server melalui **smartphone (Termius, JuiceSSH, Termux, ConnectBot)** maupun desktop PC.

Kebanyakan MOTD bawaan atau tool fetch desktop akan mengalami teks berantakan (*line-wrapping*) ketika dibuka di layar HP karena lebar terminal portrait yang sempit (~38–45 kolom). `simple-mobile-motd` secara cerdas mendeteksi lebar terminal secara *real-time* dan menyesuaikan bar visual agar tetap rapi, presisi, dan indah dipandang.

```text
  ╔═╗╔═╗╔╦╗╔═╗╦ ╦
  ╠╣ ╠═╣ ║ ╠═╣╠═╣
  ╚  ╩ ╩ ╩ ╩ ╩╩ ╩
  fatahilah • Debian GNU/Linux 13 (trixie)
────────────────────────────────────────────────────
 ✦ CPU     : Intel Xeon E5-2698 v4 @ 2.20GHz (1 Core)
 ✦ Kernel  : 6.1.0-52-cloud-amd64 (x86_64)
 ✦ Uptime  : 7h 53m | User(s): 2
 ✦ IP LAN  : 10.2.30.119 (eth0)
 ✦ IP VPN  : 100.100.2.1 (tailscale)
 ✦ IP WAN  : 129.227.46.157
────────────────────────────────────────────────────
 RAM  [◆◆◆◆◆◇◇◇◇◇◇◇◇◇◇]  34%  676M / 1.9G
 SWAP [◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇]  <1%  3M / 511M
 DISK [◆◆◇◇◇◇◇◇◇◇◇◇◇◇◇]  18%  3.3G / 20G
────────────────────────────────────────────────────
 ✦ Status  : ● Ssh ● Tailscaled
 ✦ Updates : System is up to date
────────────────────────────────────────────────────
```

---

## 🚀 Fitur Unggulan

- 📱 **Mobile-First & Responsive**: Menyesuaikan panjang progress bar dan garis pembatas secara otomatis berdasarkan ukuran layar terminal (`tput cols`).
- 🤖 **Universal Platform**: Kompatibel 100% di **Linux Server (Debian, Ubuntu, CentOS, Arch, Alpine, dll.)** dan **Termux (Android)**.
- 💎 **Diamond Progress Bar (`◆` / `◇`)**: Tampilan meter elegan bergaya RPG/Modern.
- ⚡ **Pure Bash & Ultra Fast**: Eksekusi instan tanpa dependensi runtime tambahan seperti Python, NodeJS, atau Rust.
- 💻 **Hardware & System Info**:
  - **CPU**: Menampilkan model prosesor / SoC Android & jumlah core dengan format ringkas.
  - **OS & Kernel**: Identitas distro/Termux, versi kernel, arsitektur, dan uptime.
- 📊 **Resource Progress Bars**:
  - **RAM**: Penggunaan memori real-time & kapasitas total.
  - **SWAP**: Status swap & persentase (otomatis menampilkan `<1%` atau `Off` jika tidak aktif).
  - **DISK**: Partisi root `/` (atau `/data` di Termux).
- 🌐 **Smart Network Info**: Mendeteksi IP Lokal (LAN), IP VPN (Tailscale/WireGuard/Tun), dan IP Publik (WAN) dengan caching hemat kuota/waktu.
- 🐳 **Service & Updates Monitoring**: Menampilkan status servis aktif (SSH, Docker, Tailscale, runit, dll.) dan update paket pending.
- 🎨 **Installer Interaktif**: Pilih nama banner dan tema warna langsung saat instalasi.

---

## 📥 Cara Instalasi

### 1. Metode One-Liner (Paling Cepat)

**Di Linux Server / VPS:**
```bash
curl -sSL https://raw.githubusercontent.com/fatahilah-mr/simple-mobile-motd/main/install.sh | sudo bash
```

**Di Termux (Android):**
```bash
curl -sSL https://raw.githubusercontent.com/fatahilah-mr/simple-mobile-motd/main/install.sh | bash
```

---

### 2. Metode Git Clone

```bash
git clone https://github.com/fatahilah-mr/simple-mobile-motd.git
cd simple-mobile-motd

# Untuk Linux Server:
sudo ./install.sh

# Untuk Termux:
./install.sh
```

> Saat instalasi berjalan, script akan menanyakan teks banner yang diinginkan (default: `FATAH`) dan pilihan tema warna.

---

## 📖 Panduan Penggunaan

### 1. Menampilkan MOTD Kapan Saja
Setelah terinstall, Anda dapat memanggil perintah ini di terminal:
```bash
motd-fatah
```

### 2. Mengubah Konfigurasi
File konfigurasi tersimpan di `/etc/motd-fatah/motd.conf` (atau `$PREFIX/etc/motd-fatah/motd.conf` di Termux). Edit dengan editor teks:
```bash
nano /etc/motd-fatah/motd.conf
```

### 3. Menguji Tampilan di Layar HP
Untuk mensimulasikan tampilan layar sempit (lebar 38 kolom) langsung dari terminal:
```bash
COLUMNS=38 motd-fatah
```

---

## ⚙️ Opsi Konfigurasi (`motd.conf`)

| Variabel | Pilihan Nilai | Keterangan |
| :--- | :--- | :--- |
| `BANNER_TEXT` | `"FATAH"`, `"LINUX"`, dll. | Teks ASCII Banner (disarankan 5–8 karakter untuk layar HP). |
| `THEME` | `cyan`, `green`, `purple`, `blue`, `yellow`, `rainbow`, `mono` | Tema warna tampilan MOTD. |
| `BAR_FILLED` | `"◆"`, `"█"`, `"▰"`, `"■"` | Simbol bagian bar terisi (Default: `◆`). |
| `BAR_EMPTY` | `"◇"`, `"░"`, `"▱"`, `"□"` | Simbol bagian bar kosong (Default: `◇`). |
| `BAR_WIDTH` | `auto`, `10`, `15`, `20` | Panjang progress bar (mode `auto` otomatis mengecil di HP). |
| `SHOW_HEADER` | `true` / `false` | Tampilkan Banner ASCII & info OS. |
| `SHOW_CPU_INFO` | `true` / `false` | Tampilkan Model CPU & Jumlah Core. |
| `SHOW_SYSTEM_INFO` | `true` / `false` | Tampilkan Kernel, Uptime, & User aktif. |
| `SHOW_NETWORK` | `true` / `false` | Tampilkan IP LAN, IP VPN, & IP WAN. |
| `SHOW_RESOURCES` | `true` / `false` | Tampilkan bar RAM & DISK. |
| `SHOW_SWAP` | `true` / `false` | Tampilkan status SWAP. |
| `SHOW_SERVICES` | `true` / `false` | Tampilkan status servis (Docker, SSH, dll.). |
| `SHOW_UPDATES` | `true` / `false` | Tampilkan status update paket OS. |
| `MONITOR_SERVICES`| `"ssh,docker,tailscaled,nginx"` | Daftar servis yang ingin dimonitor. |

---

## 🎨 Tema Warna yang Didukung

- 🌊 **Cyan (Default)**: Aksen neon cyan & putih bersih.
- 🌲 **Green**: Gaya terminal Matrix retro.
- 🔮 **Purple**: Nuansa Synthwave / Cyberpunk.
- 🔷 **Blue**: Nuansa biru klasik server.
- ☀️ **Yellow**: Nuansa emas / amber.
- 🌈 **Rainbow**: Gradasi multi-warna.
- ⚪ **Mono**: Tampilan monokrom minimalis.

---

## 🗑️ Cara Uninstall

Jika ingin menghapus instalasi secara bersih:

```bash
# Di Linux Server:
sudo ./uninstall.sh

# Di Termux:
./uninstall.sh
```

---

## 🤝 Panduan Kontribusi (Contributing Guide)

Kami sangat terbuka untuk kontribusi dari komunitas! Jika Anda ingin menambahkan fitur, tema baru, atau perbaikan bug, ikuti langkah-langkah berikut:

### 1. Fork & Clone Repository
```bash
git clone https://github.com/<username-kamu>/simple-mobile-motd.git
cd simple-mobile-motd
```

### 2. Buat Branch Baru dari `dev`
Semua pengembangan fitur baru dilakukan pada branch **`dev`**:
```bash
git checkout -b dev origin/dev
git checkout -b feature/nama-fitur-kamu
```

### 3. Pedoman Pengembangan (Coding Standards)
- ⚡ **Pure Bash**: Gunakan shell script murni tanpa dependensi compiler atau runtime berat.
- 📱 **Mobile-First (~38 Kolom)**: Pastikan setiap output teks tidak melebihi lebar 38–40 karakter agar tidak mengalami *line-wrapping* di smartphone. Uji dengan:
  ```bash
  COLUMNS=38 ./motd.sh
  ```
- 🌐 **Cross-Platform**: Pastikan perubahan tetap kompatibel baik di Linux Server biasa maupun di Termux Android (perhatikan penggunaan variable `$PREFIX` dan `$TMPDIR`).

### 4. Commit & Push
Gunakan format pesan commit yang jelas ([Conventional Commits](https://www.conventionalcommits.org/)):
```bash
git add .
git commit -m "feat: menambahkan tema warna baru solarized"
git push origin feature/nama-fitur-kamu
```

### 5. Buat Pull Request (PR)
Buka Pull Request di GitHub dan arahkan **Base branch ke `dev`**. Tim akan mereview dan menggabungkan kontribusi Anda!

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).
