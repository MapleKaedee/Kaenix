# Migrasi setelah clean install

## Sebelum menghapus CachyOS

Simpan seluruh repo ini di media yang bertahan melewati clean install. Repo sudah membawa video wallpaper, tema, konfigurasi desktop dan profil CTL-472. Akun, kredensial, data osu!, dan dokumen pribadi tidak termasuk salinan ini.

Daftar backup yang dipilih pengguna tersedia di [BACKUP.md](BACKUP.md). Untuk melanjutkan melalui chat baru setelah migrasi, gunakan [ringkasan konteks](CONTINUE-IN-NIXOS.md) dan [salinan percakapan](chat/2026-10-16-cachyos-nixos.md).

## Masukkan baseline instalasi baru

1. Selesaikan clean install dan pastikan instalasi dasar bisa boot serta pengguna `kaede` memiliki password.
2. Salin `/etc/nixos/hardware-configuration.nix` dari instalasi tersebut ke root repo, menggantikan file lama.
3. Buka `/etc/nixos/configuration.nix` hasil installer. Salin semua pengaturan `boot.loader` yang relevan ke atribut `bootLoader` dalam `installation.nix`. Bootloader tidak ikut otomatis dalam file hardware.
4. Salin `system.stateVersion` installer ke `systemStateVersion`. Untuk home baru, tetapkan `homeStateVersion` sesuai baseline Home Manager yang dipilih; nilai awal repo `26.05`. Setelah diterapkan, jangan naikkan state version hanya karena memperbarui paket.
5. Setelah hardware dan bootloader sesuai, set `hardwareReady = true`.

Contoh **hanya jika installer memang memakai systemd-boot UEFI**:

```nix
{
  hardwareReady = true;
  systemStateVersion = "26.05";
  homeStateVersion = "26.05";
  bootLoader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
```

Untuk GRUB, gunakan pengaturan GRUB dari installer. Jika instalasi membutuhkan konfigurasi lain seperti secure boot, enrollment, atau mount khusus di luar file hardware, pertahankan konfigurasi tersebut dari instalasi yang sudah berhasil boot.

## Build dan terapkan

Jalankan dari root repo pada NixOS baru:

```bash
nix build --no-link .#checks.x86_64-linux.seed-files .#checks.x86_64-linux.seed-integration .#checks.x86_64-linux.niri-config
nix flake check --no-build
sudo nixos-rebuild build --flake .#syrup
sudo nixos-rebuild boot --flake .#syrup
sudo reboot
```

`boot` menyiapkan generasi untuk reboot, sehingga penggantian compositor/driver tidak mematikan sesi saat ini. Setelah masuk melalui DankGreeter, periksa layanan dan fungsi di bawah. Jangan menjalankan activation package Home Manager repo ini terhadap home CachyOS aktif untuk sekadar mengetesnya.

## Pemeriksaan di mesin target

- Login dan logout DankGreeter; lock/unlock memakai password sistem.
- `systemctl --user status dms opentabletdriver`; pastikan tidak ada instance DMS atau agen Polkit ganda.
- Kitty membuka Fish dengan Starship dan satu Fastfetch; warna/tab sesuai Catppuccin.
- Ubah tema DMS, area tablet, dan wallpaper; rebuild lalu pastikan perubahan GUI tetap tersimpan.
- Brave menjadi browser default; file chooser dan screen sharing berfungsi.
- Brightness, audio/mic, network, Bluetooth, notifikasi, screenshot, clipboard, shortcut Niri.
- `asusctl` dan ROG Control Center bisa membaca/mengubah fitur yang didukung hardware.
- Wacom CTL-472 terdeteksi; uji area, rotasi 180°, dan input di osu!lazer. Hindari menjalankan driver tablet bawaan osu! bersamaan dengan OTD eksternal jika keduanya berebut perangkat.
- `nvidia-smi` bekerja; desktop memakai AMD dan `nvidia-offload 'osu!'` memakai NVIDIA.
- Suspend/resume, monitor eksternal, video wallpaper, serta konsumsi daya saat idle.

Jika deployment pertama bermasalah, pilih generasi instalasi dasar dari menu boot. File GUI writable tidak di-rollback bersama generasi; lihat [kepemilikan konfigurasi](CONFIGURATION.md).
