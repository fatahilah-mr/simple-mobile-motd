<div align="center">

# 📱 motd-fatah

**A lightweight, responsive, and mobile-friendly Message of the Day (MOTD) for Linux servers.**

[![Shell Script](https://img.shields.io/badge/Language-Bash%205%2B-blue.svg?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Mobile Friendly](https://img.shields.io/badge/Optimized-Mobile%20SSH-brightgreen.svg?style=flat-square)](https://github.com)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero%20(Pure%20Bash)-orange.svg?style=flat-square)](https://github.com)

</div>

---

## ✨ Overview

**`motd-fatah`** dirancang khusus untuk administrator server dan developer yang sering mengakses server melalui **smartphone (Termius, JuiceSSH, Termux, ConnectBot)** maupun desktop PC.

Kebanyakan MOTD bawaan atau tool fetch desktop akan mengalami teks berantakan (*line-wrapping*) ketika dibuka di layar HP karena lebar terminal portrait yang sempit (~38–45 kolom). `motd-fatah` secara cerdas mendeteksi lebar terminal secara *real-time* dan menyesuaikan bar visual agar tetap rapi, presisi, dan indah dipandang.

```text
  ╔═╗╔═╗╔╦╗╔═╗╦ ╦
  ╠╣ ╠═╣ ║ ╠═╣╠═╣
  ╚  ╩ ╩ ╩ ╩ ╩╩ ╩
  fatahilah • Debian GNU/Linux 13 (trixie)
────────────────────────────────────────────────────
 ✦ CPU     : Intel Xeon E5-2698 v4 @ 2.20GHz (1 Core)
 ✦ Kernel  : 6.1.0-52-cloud-amd64 (x86_64)
 ✦ Uptime  : 7h 46m | User(s): 2
 ✦ IP LAN  : 10.2.30.119 (eth0)
 ✦ IP VPN  : 100.100.2.1 (tailscale)
 ✦ IP WAN  : 129.227.46.157
────────────────────────────────────────────────────
 RAM  [████░░░░░░░░░░░]  33%  662M / 1.9G
 SWAP [░░░░░░░░░░░░░░░]  <1%  3M / 511M
 DISK [██░░░░░░░░░░░░░]  18%  3.3G / 20G
────────────────────────────────────────────────────
 ✦ Status  : ● Ssh ● Tailscaled
 ✦ Updates : System is up to date
────────────────────────────────────────────────────
```

---

## 🚀 Fitur Unggulan

- 📱 **Mobile-First & Responsive Layout**: Menyesuaikan panjang progress bar dan garis pembatas secara otomatis berdasarkan ukuran layar terminal (`tput cols`).
- ⚡ **Pure Bash & Ultra Fast**: Eksekusi instan tanpa dependensi runtime tambahan seperti Python, NodeJS, atau Rust.
- 💻 **Hardware & System Info**:
  - **CPU**: Menampilkan model prosesor & jumlah core dengan format ringkas.
  - **OS & Kernel**: Identitas distro, versi kernel, arsitektur, dan uptime.
- 📊 **Resource Progress Bars**:
  - **RAM**: Penggunaan memori real-time & kapasitas total.
  - **SWAP**: Status swap & persentase (otomatis menampilkan `<1%` atau `Off` jika tidak aktif).
  - **DISK**: Partisi root `/` (Used / Total).
- 🌐 **Smart Network Info**: Mendeteksi IP Lokal (LAN), IP VPN (Tailscale/WireGuard), dan IP Publik (WAN) dengan caching hemat kuota/waktu.
- 🐳 **Service & Package Updates Monitoring**: Menampilkan status servis aktif (SSH, Docker, Nginx, Tailscale, dll.) dan jumlah update paket pending.
- 🎨 **Modular & Kustomisasi Mudah**: File konfigurasi terpisah di `/etc/motd-fatah/motd.conf`.

---

## 📥 Cara Instalasi

### 1. Metode Git Clone (Direkomendasikan)

```bash
git clone https://github.com/fatahilah/motd-fatah.git
cd motd-fatah
sudo ./install.sh
```

### 2. Metode One-Liner (Curl / Wget)

```bash
curl -sSL https://raw.githubusercontent.com/fatahilah/motd-fatah/main/install.sh | sudo bash
```

---

## ⚙️ Konfigurasi (`motd.conf`)

Setelah diinstal, file konfigurasi tersimpan di `/etc/motd-fatah/motd.conf`. Anda dapat mengeditnya kapan saja:

```bash
sudo nano /etc/motd-fatah/motd.conf
```

### Opsi yang Tersedia:

| Variabel | Pilihan Nilai | Keterangan |
| :--- | :--- | :--- |
| `BANNER_TEXT` | `"FATAH"`, `"LINUX"`, dll. | Teks ASCII Banner (disarankan 5–8 karakter untuk layar HP). |
| `THEME` | `cyan`, `green`, `purple`, `blue`, `yellow`, `rainbow`, `mono` | Tema warna tampilan MOTD. |
| `BAR_WIDTH` | `auto`, `10`, `15`, `20` | Panjang progress bar (mode `auto` otomatis mengecil di HP). |
| `SHOW_HEADER` | `true` / `false` | Tampilkan Banner ASCII & info OS. |
| `SHOW_CPU_INFO` | `true` / `false` | Tampilkan Model CPU & Jumlah Core. |
| `SHOW_SYSTEM_INFO` | `true` / `false` | Tampilkan Kernel, Uptime, & User aktif. |
| `SHOW_NETWORK` | `true` / `false` | Tampilkan IP LAN, IP VPN, & IP WAN. |
| `SHOW_RESOURCES` | `true` / `false` | Tampilkan bar RAM & DISK. |
| `SHOW_SWAP` | `true` / `false` | Tampilkan status SWAP. |
| `SHOW_SERVICES` | `true` / `false` | Tampilkan status servis (Docker, SSH, dll.). |
| `SHOW_UPDATES` | `true` / `false` | Tampilkan status update paket OS. |
| `MONITOR_SERVICES`| `"ssh,docker,tailscaled,nginx"` | Daftar servis systemd yang ingin dimonitor. |

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

## 🧪 Menguji Tampilan

Jalankan perintah ini di terminal kapan saja untuk melihat preview langsung:

```bash
motd-fatah
```

---

## 🗑️ Cara Uninstall

Jika ingin menghapus instalasi secara bersih:

```bash
sudo ./uninstall.sh
```

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).
