# Validasi rewrite — 16 Oktober 2026

## Lingkungan dan batasan

Pemeriksaan dilakukan dari CachyOS. Nix sistem tidak terpasang; Nix portable 2.20.6 diunduh dari rilis upstream dan dijalankan dengan store serta cache di `/tmp/kaenix-nix` dan `/tmp/kaenix-cache`. Tidak ada `nixos-rebuild switch`, aktivasi Home Manager, perubahan partisi, atau pemasangan driver ke host CachyOS.

Evaluasi derivasi bukan build seluruh sistem. Build kernel/NVIDIA, seluruh closure NixOS/Home Manager, boot, login, suspend, dan interaksi perangkat harus diverifikasi setelah clean install. Pengujian berikut tidak mengklaim perangkat keras sudah berfungsi di NixOS.

## Hasil

| Pemeriksaan | Hasil |
| --- | --- |
| `nix flake update --flake path:...` | Lolos; lockfile nyata diperbarui oleh Nix, bukan hash buatan. |
| Evaluasi activation package Home Manager | Lolos, seluruh opsi dan derivasi pengguna ter-resolve. |
| Evaluasi `tests/evaluate.nix` | Lolos untuk derivasi sistem lengkap dengan fixture disk/boot sintetis. |
| Pengaman output sistem asli | Berhasil menolak deployment: `hardwareReady = false` dan bootloader belum diisi. |
| `checks.x86_64-linux.seed-files` | Build lolos; 4 tes: file writable, edit GUI bertahan, symlink target tidak ditimpa, parent symlink/path keluar home ditolak. |
| `checks.x86_64-linux.niri-config` | Build lolos memakai Niri dari lockfile; base tanpa fragmen dan base dengan seluruh fragmen DMS valid. |
| `checks.x86_64-linux.seed-integration` | Build lolos; seluruh 16 file seed dari konfigurasi Home Manager cocok dengan baseline, JSON valid, dan edit GUI bertahan saat dijalankan ulang. |
| File Kitty/Fish hasil Home Manager | Keduanya berhasil dibangun terpisah. Kitty parser lokal mengembalikan daftar error kosong; `fish -n` exit 0. |
| Fastfetch hasil evaluasi settings | Fastfetch lokal menerima konfigurasi; exit 0. |
| Aset JSON/TOML | Seluruh baseline JSON/TOML berhasil diparse. |
| Video wallpaper | SHA-256 salinan cocok dengan sumber CachyOS. |
| Kepemilikan runtime | Seed setelah `linkGeneration`, sebelum `reloadSystemd`; satu layanan HM `dms`; tidak ada layanan pengguna Polkit eksternal. |
| Sisa konfigurasi lama | Tidak ada Noctalia, Zsh/Oh My Zsh, `dotfilesRoot`, out-of-store symlink, variabel Firefox, atau path Downloads dalam konfigurasi aktif. |

## Versi yang dievaluasi

| Komponen | Versi/revisi |
| --- | --- |
| nixpkgs | `55bfb4d7437bd4e09ab7cba58a43bd68eb310044` |
| Home Manager utama | `640725978b99076e18e069f6e7d2959124584f8f` |
| Chaotic | `c29e457d3fd66586f09d2f34c08b9383454e5cd7` |
| DMS | `1.6.3+date=2026-10-07_4a87e82` |
| Niri | `26.04` |
| Kernel CachyOS | `7.2.10` |
| NVIDIA | `615.78.08`, open module dipilih |
| Fish | `4.9.3` |

Fixture mempertahankan modul sistem dan paket yang sama, tetapi mengganti disk dengan label fiktif, memakai systemd-boot uji, dan mengaktifkan hardwareReady hanya di proses evaluasi. `installation.nix` asli tetap tidak siap deployment. Fixture tidak diekspos sebagai profil instalasi.

## Mengulang pemeriksaan

```bash
python3 -m unittest discover -s tests -v
nix build --no-link .#checks.x86_64-linux.seed-files .#checks.x86_64-linux.seed-integration .#checks.x86_64-linux.niri-config
nix eval --impure --json --expr 'import ./tests/evaluate.nix { flake = builtins.getFlake ("path:" + toString ./.); }'
```

Setelah hardware/bootloader instalasi baru diisi, jalankan `nix flake check --no-build` dan `nixos-rebuild build --flake .#syrup` untuk konfigurasi target nyata. Daftar pengujian runtime ada dalam [panduan migrasi](MIGRATION.md).

## Temuan yang sudah diperbaiki selama validasi

- Atribut paket `rog-control-center` tidak tersedia pada nixpkgs yang terkunci; GUI sudah dibundel oleh `asusctl`, sehingga cukup mengaktifkan modul asusd.
- Opsi settings/session DMS akan menghasilkan symlink read-only; seed writable digunakan untuk mempertahankan penyimpanan GUI.
- Home Manager menghasilkan file Kitty/Fish melalui derivasi `.source`, bukan selalu `.text`; validasi akhir dilakukan terhadap file hasil build.

Checksum video: `12e885065003aa2a30852845459d3395962a5e5e1d22e6c6c251ef153bca9674`.
