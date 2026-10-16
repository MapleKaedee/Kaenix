# Catatan perubahan

## 2026-10-16 — Backup dan kelanjutan chat

- Tambah `docs/BACKUP.md` sesuai pilihan pengguna: data pribadi, osu!, pengaturan/state DMS, aset DMS di Niri/Kitty, repo, dan percakapan proyek. Catat komponen yang tidak perlu dibackup.
- Ekspor pesan percakapan yang tersedia ke `docs/chat/2026-10-16-cachyos-nixos.md`, tanpa output tools, reasoning, atau instruksi internal. Snapshot tidak mencakup jawaban akhir turn ekspor.
- Tambah `docs/CONTINUE-IN-NIXOS.md` untuk dibaca ChatGPT/Codex pada chat baru; memuat keputusan, hasil implementasi, batas validasi, dan langkah setelah clean install.
- Perbarui tautan README dan panduan migrasi. Riwayat diff rewrite tetap snapshot historis, tidak ditulis ulang.
- Riwayat Codex lokal ditemukan dalam `.codex` dan profil aplikasi `.config/Codex`; dokumentasikan backup mentah setelah aplikasi berhenti tanpa menjanjikan impor native lintas versi.
- Belum ada penyalinan ke hard disk eksternal karena media belum terdeteksi terpasang. Tidak ada data aplikasi aktif yang diubah.

## 2026-10-16 — Rewrite CachyOS → NixOS

Status: implementasi repo; belum diterapkan ke sistem operasi. Rincian bukti pemeriksaan ada di [VALIDATION.md](docs/VALIDATION.md). Setiap file konfigurasi yang berubah dicatat di [inventaris dan diff](docs/changes/2026-10-16-rewrite.md).

| Area | Sebelum | Sesudah dan alasan |
| --- | --- | --- |
| Hardware/boot | UUID lama dan GRUB dipaksakan | Hardware lama dipertahankan sebagai placeholder; `installation.nix` menampung bootloader/state version dan memblokir deployment sebelum diganti. |
| Input flake | Niri flake + Noctalia | Niri nixpkgs + DMS stable; plugin pada commit yang sudah digunakan; lockfile diperbarui oleh Nix. |
| Dotfile | Symlink ke `/home/kaede/nnn` | Home Manager membangun konfigurasi dan aset dari repo; lokasi checkout bebas. |
| Shell | Zsh + Oh My Zsh | Fish + Starship + eza + autopair; Fastfetch hanya di greeting Fish. |
| Kitty | Konfigurasi dasar lama | Tampilan/shortcut CachyOS; tema DMS writable; baris `fastfetch` yang tidak valid dihapus. |
| Fastfetch | Konfigurasi lama | Tampilan Maple-Tree dan `hakufetch.txt`; settings melalui Home Manager. |
| Niri | Flake eksternal, dotfile lama | Modul bawaan nixpkgs, base KDL CachyOS, render AMD eksplisit, include DMS opsional. Notifikasi kesalahan kembali aktif. |
| Desktop shell | Noctalia + script wallpaper setiap rebuild | DMS satu layanan pengguna; Catppuccin dan pengaturan awal disalin hanya jika belum ada. |
| Login/lock | Noctalia Greeter | DankGreeter + sesi Niri; PAM sistem; tanpa auto-login. |
| Plugin | Tidak dideklarasikan | catWidget + mpvpaper dikunci; konfigurasi plugin dapat disimpan GUI. |
| Wallpaper | Direktori di repo eksternal | Video lokal disertakan dan dipasang ke `~/Pictures/Wallpapers`; path Downloads dihapus. |
| GPU | NVIDIA closed + PRIME sync + override derivasi | NVIDIA open + offload + pengelolaan daya; hapus `allowedReferences` workaround. |
| Browser | Brave terpasang, variabel Firefox global | Brave via Home Manager + MIME default; hapus variabel Firefox dan pemaksaan VA-API NVIDIA global. |
| ASUS | asusd/asusctl | asusd tetap aktif; paket asusctl 6.5.0 di lockfile juga menyediakan ROG Control Center. Tidak ada paket `rog-control-center` terpisah di nixpkgs ini. |
| Tablet | Tidak ada | Modul OpenTabletDriver, daemon/udev; profil CTL-472 disalin sekali; autostart manual Niri dihapus. |
| Gaming | Tidak ada osu!lazer | `osu-lazer-bin` untuk distribusi resmi dengan fitur online. |
| Backup HM | `.backup` bisa ditimpa | `.pre-kaenix` tidak ditimpa; konflik cadangan perlu ditangani eksplisit. |
| Validasi | Tidak ada checks | Tes seed, validasi Niri sebelum/sesudah fragmen DMS, serta fixture evaluasi sistem. |

### Keputusan implementasi

- Konfigurasi awal DMS menjadi atribut Nix; settings/session resmi tidak dipakai untuk menyimpan state aktif karena menghasilkan symlink read-only.
- File seed dibuat atomik dengan mode `0600`, dijalankan setelah link Home Manager dan sebelum reload layanan. File yang ada tidak diganti; symlink direktori lama ditolak.
- Base KDL tetap file yang dibaca Nix; input `niri-flake` tidak diperlukan. Fragmen DMS yang writable mengikuti baseline CachyOS.
- `asusctl` sudah memuat ROG Control Center menurut derivasi yang terkunci. Mengaktifkan asusd memasang keduanya; entri paket terpisah akan menyebabkan evaluasi gagal.
- Direnv/Zoxide tidak ditambahkan karena belum terpasang pada sumber CachyOS; hook kondisional lama tidak dibawa. Riwayat shell, launcher, clipboard, akun, dan data osu! tidak disalin.
- Paket umum yang tidak terkait rewrite tetap dipertahankan. `grub2`/`os-prober` dilepas dari paket eksplisit; pemasangan bootloader mengikuti modul hasil clean install.
- Foto wallpaper lama tetap disimpan dalam `collection/` agar tidak menghapus aset pengguna yang tidak terkait.

### Cara melacak perubahan berikutnya

Tambahkan entri bertanggal dengan daftar perubahan, alasan, file terkait, hasil tes, dan batasan runtime. Untuk konfigurasi GUI yang ingin direproduksi, ekspor kembali ke baseline; rebuild biasa sengaja tidak menimpa state aktif.
