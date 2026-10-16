# Backup yang dipilih sebelum clean install

Keputusan pengguna pada 16 Oktober 2026: backup dilakukan ke hard disk eksternal. Disk eksternal belum terdeteksi terpasang saat dokumen ini dibuat; belum ada penyalinan ke disk eksternal.

## Daftar yang disalin

| Isi | Sumber saat ini |
| --- | --- |
| Data pribadi | Folder/file pilihan pengguna |
| Seluruh data osu!lazer, termasuk database | `/home/kaede/.local/share/osu/` |
| Pengaturan, plugin, dan tema DMS | `/home/kaede/.config/DankMaterialShell/` |
| State DMS | `/home/kaede/.local/state/DankMaterialShell/` |
| Fragmen Niri yang ditulis DMS | `/home/kaede/.config/niri/dms/` |
| Tema Kitty yang ditulis DMS | `/home/kaede/.config/kitty/dank-theme.conf` dan `/home/kaede/.config/kitty/dank-tabs.conf` |
| Seluruh repo beserta aset, video, lockfile, dan dokumentasi | `/home/kaede/Downloads/kaenix/` |

Fragmen Niri dan tema Kitty termasuk backup pengaturan DMS karena DMS menyimpan hasil pengaturannya di luar direktorinya sendiri. Repo sudah menyimpan baseline, tetapi backup aktif mempertahankan perubahan GUI setelah baseline itu disalin.

Tutup osu! sebelum menyalin direktorinya agar database dan filenya konsisten. Hentikan DMS sebelum salinan akhir state desktop. Jika media eksternal memakai exFAT/NTFS, arsip tar dapat mempertahankan metadata/symlink Linux di dalam satu file; verifikasi arsip dapat dibaca sebelum clean install.

## Chat untuk dibaca dan dilanjutkan

- [Transkrip percakapan proyek](chat/2026-10-16-cachyos-nixos.md): pesan pengguna dan jawaban/update asisten yang tersedia sampai ekspor dibuat.
- [Ringkasan konteks dan langkah berikutnya](CONTINUE-IN-NIXOS.md): keputusan penting termasuk jawaban dialog pilihan, status implementasi, dan pekerjaan yang menunggu clean install.

Keduanya ikut tersimpan jika seluruh repo dibackup. Di chat baru, lampirkan ringkasan dan minta asisten membaca README serta panduan migrasi repo sebelum melanjutkan. Transkrip dapat dilampirkan jika perlu detail tambahan. Markdown ini tidak mengimpor chat lama ke sidebar ChatGPT.

## Cadangan mentah Codex lokal, jika ingin mempertahankannya

Riwayat lokal ditemukan di `/home/kaede/.codex/`, termasuk `sessions/` dan database state/history. Profil aplikasi ditemukan di `/home/kaede/.config/Codex/`.

Untuk mempertahankan salinan mentah, **tutup seluruh aplikasi/proses Codex sebelum membuat arsip akhir** kedua direktori. Jangan menyalin database SQLite aktif satu per satu: data terbaru dapat berada dalam file WAL. Arsip mentah ini berguna sebagai cadangan, tetapi pemulihan riwayat native lintas versi/OS belum diverifikasi. Login ulang setelah instalasi dapat diperlukan.

Arsip `.codex` juga dapat memuat token login dan percakapan lain. Simpan sebagai backup privat, terpisah dari repo yang mungkin dipublikasikan. Transkrip Markdown proyek ini hanya menyalin pesan percakapan, tanpa file autentikasi, output tools, reasoning, atau instruksi internal.

## Tidak dipilih untuk backup

Profil Brave (password/bookmark sudah dibackup), keyrings, profil ASUS/tablet aktif, editor/skrip, dan koneksi jaringan tidak perlu disalin sesuai keputusan pengguna. Ini tidak menghapus baseline yang sudah ada dalam repo.

## Verifikasi sebelum format

- Buka beberapa file pribadi dari hard disk eksternal.
- Pastikan direktori/arsip osu! lengkap, bukan hanya subdirektori `files/`.
- Buka README repo, transkrip chat, dan ringkasan konteks dari hasil backup.
- Pastikan video wallpaper tersedia dalam `collection/` repo.
- Simpan salinan sampai instalasi baru dan pemulihan data sudah diverifikasi.
