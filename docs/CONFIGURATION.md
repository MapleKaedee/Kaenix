# Kepemilikan konfigurasi

## Deklaratif melalui Home Manager

Kitty, Fish, Starship, Fastfetch, Brave/MIME, base Niri, sumber plugin, dan file wallpaper dikelola Nix. Ubah modul atau aset repo lalu rebuild. Jangan mengedit symlink hasil Home Manager secara langsung.

Kitty, Fish, dan Fastfetch memakai opsi `programs.*`. Niri memakai `xdg.configFile."niri/config.kdl".text`, membaca KDL yang disimpan di repo. Cara ini mempertahankan fitur Niri tanpa bergantung pada skema modul Niri eksternal.

## Writable dan disalin sekali

`kaenix.seedFiles` menjalankan `scripts/seed-files.py` setelah link Home Manager dan sebelum reload systemd. Manifest bersumber dari Nix store; target selalu relatif terhadap home pengguna.

| Target | Sumber awal | Pemilik setelah aktivasi |
| --- | --- | --- |
| `~/.config/DankMaterialShell/settings.json` | `config/dms/settings.nix` | GUI DMS |
| `~/.config/DankMaterialShell/plugin_settings.json` | `modules/home/dms-home.nix` | GUI plugin DMS |
| `~/.local/state/DankMaterialShell/session.json` | State minimal, tanpa riwayat launcher | DMS |
| `~/.config/DankMaterialShell/themes/catppuccin/theme.json` | `config/dms/catppuccin.json` | DMS |
| `~/.config/niri/dms/*.kdl` | `config/niri/dms/` | DMS/pengguna |
| `~/.config/kitty/dank-*.conf` | `config/kitty/` | Generator tema DMS |
| `~/.config/OpenTabletDriver/settings.json` | `config/opentabletdriver/settings.json` | GUI OpenTabletDriver |

Mengubah baseline tidak mengganti file aktif yang sudah ada, termasuk file kosong atau symlink. Untuk menerapkan ulang satu baseline, hentikan aplikasi terkait, pindahkan file aktif ke cadangan yang unik, lalu rebuild. Jangan memindahkan seluruh direktori DMS karena sumber plugin dikelola Home Manager.

Jika `.config/niri` atau direktori induk target masih berupa symlink out-of-store dari konfigurasi lama, ubah menjadi direktori biasa setelah membuat cadangan. Helper menolak menulis melalui symlink direktori, bukan mengikuti symlink ke repo lama.

Rollback generasi NixOS memulihkan konfigurasi deklaratif dan sumber plugin, tetapi tidak memulihkan state GUI. Cadangkan state writable secara terpisah jika ingin rollback tampilan atau area tablet.

## Membawa perubahan GUI kembali ke repo

Ekspor pengaturan DMS dengan `dms ipc call settings dump`, kemudian terjemahkan nilai yang ingin dijadikan baseline ke `config/dms/settings.nix`. Jangan menyalin path absolut pengguna lain, riwayat pencarian, atau kredensial.

Fragmen Niri, tema Kitty, dan profil tablet dapat disalin kembali ke lokasi baseline masing-masing setelah diperiksa. `fish_variables` tidak diperlukan: prompt dan plugin dikelola lewat modul Fish.

Plugin dikunci di input flake. GUI bisa mengubah pengaturan, tetapi memperbarui/menghapus kode plugin harus dilakukan lewat Nix. Setelah mengganti commit input, jalankan `nix flake update cat-widget mpvpaper-plugin` dan uji kembali kompatibilitasnya.

## GPU dan aplikasi

Niri menggunakan render node AMD berdasarkan PCI `0000:05:00.0`. NVIDIA pada `0000:01:00.0` tersedia untuk aplikasi tertentu:

```bash
nvidia-offload 'osu!'
```

Tidak ada pemaksaan driver VA-API NVIDIA untuk semua aplikasi. Jika nama konektor layar berubah setelah migrasi, pilih kembali monitor wallpaper melalui pengaturan mpvpaper; seed sekarang memakai `eDP-2` sesuai CachyOS.

DMS memakai satu layanan pengguna `dms.service`. Tidak ada `spawn-at-startup` DMS atau OpenTabletDriver dalam base Niri. Autostart OTD disediakan modul NixOS; agen Polkit menggunakan DMS.
