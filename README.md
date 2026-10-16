# kaenix — syrup

Konfigurasi NixOS + Home Manager untuk `kaede`, berdasarkan desktop CachyOS pada 16 Oktober 2026. Desktop: Niri, DankMaterialShell, DankGreeter, Fish, Kitty, Fastfetch, Brave, ASUS utilities, OpenTabletDriver, dan osu!lazer.

**Belum untuk langsung di-switch:** `hardware-configuration.nix` masih berasal dari instalasi lama. `installation.nix` sengaja menolak deployment sampai hardware, bootloader, dan state version instalasi baru sudah dimasukkan.

## Dokumentasi

- [Catatan perubahan](CHANGELOG.md)
- [Panduan clean install dan migrasi](docs/MIGRATION.md)
- [Daftar backup pilihan pengguna](docs/BACKUP.md)
- [Konteks untuk melanjutkan chat di NixOS](docs/CONTINUE-IN-NIXOS.md)
- [Kepemilikan konfigurasi dan perubahan GUI](docs/CONFIGURATION.md)
- [Hasil dan cara mengulang validasi](docs/VALIDATION.md)
- [Inventaris dan diff rewrite](docs/changes/2026-10-16-rewrite.md)

## Struktur

- `flake.nix`, `flake.lock`: sumber paket terkunci; output tetap `nixosConfigurations.syrup`.
- `installation.nix`: pengaturan khusus instalasi, bootloader, dan state version.
- `configuration.nix`, `modules/env/`: sistem, hardware, layanan, GPU, pengguna.
- `home.nix`, `modules/home/`: aplikasi dan konfigurasi pengguna.
- `config/`: konfigurasi dasar dan seed writable; tidak merujuk home CachyOS.
- `collection/`: wallpaper, termasuk video yang digunakan mpvpaper.
- `scripts/`, `tests/`: seed idempoten dan pemeriksaan konfigurasi.

## Pemeriksaan

Jalankan dari root repo pada mesin yang memiliki Nix dengan flakes aktif:

```bash
python3 -m unittest discover -s tests -v
nix build --no-link .#checks.x86_64-linux.seed-files .#checks.x86_64-linux.seed-integration .#checks.x86_64-linux.niri-config
nix eval --impure --json --expr 'import ./tests/evaluate.nix { flake = builtins.getFlake ("path:" + toString ./.); }'
```

Fixture evaluasi memakai disk fiktif untuk memeriksa seluruh derivasi sistem sebelum clean install. Fixture bukan konfigurasi untuk di-boot atau di-deploy. `nix flake check` terhadap output sistem asli akan tetap tertahan pengaman instalasi sampai langkah migrasi selesai.

Jika repo ini dimasukkan ke Git, pastikan seluruh file baru termasuk video wallpaper ditambahkan ke index sebelum menggunakan flake Git; file untracked tidak ikut sumber flake tersebut. Checkout saat rewrite tidak memiliki metadata Git yang dapat dipakai, sehingga perubahan dicatat dalam Markdown dan diff, tanpa commit otomatis.

## Referensi

- [NixOS & Flakes Book — Home Manager](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/start-using-home-manager)
- [DMS — integrasi NixOS/Home Manager](https://danklinux.com/docs/dankmaterialshell/nixos-flake)
- [DankGreeter — NixOS](https://danklinux.com/docs/dankgreeter/nixos)
- [DMS — autentikasi lock screen](https://danklinux.com/docs/dankmaterialshell/lock-screen-authentication)

Detail opsi mengikuti sumber yang dikunci dalam `flake.lock`; dokumentasi upstream dapat berubah.
