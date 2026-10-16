# Konteks untuk melanjutkan di NixOS / ChatGPT

Dokumen ini dapat dilampirkan ke chat baru bersama repo kaenix. Ringkasan proyek sampai 16 Oktober 2026; transkrip tersedia di [salinan percakapan](chat/2026-10-16-cachyos-nixos.md).

## Tujuan dan keputusan pengguna

- Migrasi dari CachyOS ke NixOS melalui clean install, kemudian memakai repo `kaenix`.
- Pengguna `kaede`, hostname `syrup`, zona waktu `Asia/Jakarta`.
- Home Manager terintegrasi ke modul NixOS; konfigurasi Kitty/Fish/Fastfetch memakai opsi Nix. Base Niri tetap KDL yang dihasilkan Home Manager.
- Fish menggantikan Zsh. Desktop memakai Niri, DankMaterialShell (DMS), dan DankGreeter menggantikan Noctalia.
- Pengaturan DMS mengikuti model Nix + GUI: Nix menyediakan baseline, file runtime writable disalin hanya jika belum ada. Rebuild tidak menimpa perubahan GUI.
- Tema Catppuccin Mocha/Mauve, plugin catWidget dan mpvpaper, video wallpaper dari CachyOS ikut dibawa.
- Kernel CachyOS dipertahankan melalui Chaotic; NVIDIA open dan hybrid/offload. Desktop memakai AMD Radeon 680M, aplikasi tertentu dapat memakai RTX 3060 Mobile.
- Brave menjadi browser default. asusd/asusctl menyediakan ROG Control Center. OpenTabletDriver dan osu-lazer-bin ikut dipasang.
- Seluruh perubahan perlu dicatat dalam Markdown.

## Status implementasi

Rewrite sudah dilakukan dalam repo. Belum diterapkan ke sistem operasi. Dokumentasi utama:

- [README](../README.md)
- [Changelog](../CHANGELOG.md)
- [Migrasi](MIGRATION.md)
- [Kepemilikan konfigurasi](CONFIGURATION.md)
- [Validasi](VALIDATION.md)
- [Inventaris dan diff rewrite](changes/2026-10-16-rewrite.md)

Lockfile diperbarui oleh Nix. Evaluasi derivasi sistem lengkap menggunakan fixture disk sintetis serta evaluasi Home Manager berhasil. Tiga build pengujian lolos: helper seed, integrasi 16 file seed, dan validasi Niri sebelum/sesudah fragmen DMS tersedia. Konfigurasi Kitty/Fish hasil Home Manager berhasil dibangun dan diparse. Belum dilakukan build seluruh sistem atau uji hardware NixOS.

## Langkah berikutnya setelah clean install

1. Letakkan repo di lokasi yang diinginkan; konfigurasi tidak bergantung pada lokasi repo lama.
2. Ganti `hardware-configuration.nix` dengan hasil instalasi NixOS baru. File dalam repo masih dari instalasi lama.
3. Isi `installation.nix`: bootloader dan stateVersion dari baseline instalasi. Setelah benar, set `hardwareReady = true`; pengaman saat ini masih `false`.
4. Pulihkan data osu! dan state DMS dari backup saat aplikasi terkait berhenti. Perhatikan kepemilikan file pengguna.
5. Ikuti pemeriksaan dan perintah build di panduan migrasi. Jangan deploy fixture dalam `tests/evaluate.nix`.
6. Uji login/lock, desktop, Brave, ASUS, tablet, osu!, offload NVIDIA, suspend/resume, dan layar eksternal.

Nix portable untuk validasi sebelumnya berada di `/tmp`; itu alat sementara dan tidak perlu ikut backup.

## Keputusan backup terbaru

Backup ke hard disk eksternal: data pribadi, seluruh data osu!, pengaturan/state DMS beserta fragmen Niri dan tema Kitty hasil DMS, seluruh repo kaenix, serta salinan chat/ringkasan ini.

Pengguna tidak memerlukan backup profil Brave, keyrings, profil ASUS/tablet aktif, editor/skrip, maupun koneksi jaringan. Password dan bookmark Brave sudah diamankan tersendiri; ASUS/tablet akan disetel ulang. Baseline profil tablet lama tetap ada di repo sebagai bagian implementasi terdahulu.

Salinan Markdown mempertahankan konteks yang dapat dibaca atau dilampirkan ke ChatGPT. Ini bukan jaminan pemulihan sidebar/chat Codex dan bukan format impor percakapan native. Jika perlu mempertahankan data mentah aplikasi, simpan arsip `.codex` dan `.config/Codex` secara terpisah setelah menutup aplikasi; pemulihan lintas versi belum diuji.
