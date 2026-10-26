# Reinstalling and adapting Kaenix

Updated: 25 October 2026. Use this guide for reinstallation or adaptation to another machine. For routine changes on `syrup`, use the [README](../README.md#getting-started).

## Current configuration

The repository is at `/home/kaede/Kaenix` and targets NixOS host `syrup` with user `kaede`. `installation/installation.nix` contains `hardwareReady = true`, UEFI GRUB, and both `systemStateVersion` and `homeStateVersion` set to `26.11`. The hardware configuration UUIDs matched the machine's mounts during the 18 October 2026 review.

This does not guarantee compatibility with another machine.

## Prepare the target installation

1. Create and verify a [backup](BACKUP.md) before erasing or replacing an installation. The repository does not store application accounts, credentials, or the user's osu! data.
2. Complete a basic installation that can boot. Ensure that the target account has a password and that a copy of the installer's configuration is available for recovery.
3. During adaptation, block deployment with `hardwareReady = false` in `installation/installation.nix` until the target hardware and bootloader have been checked. The host readiness assertion blocks deployment; never bypass it for a real installation.
4. Replace `installation/hardware-configuration.nix` with the configuration generated on the target. Preserve the mounts, subvolumes, swap, and initrd settings required by that installation.
5. Copy the appropriate bootloader settings from the installer's configuration to `installation/installation.nix`. The hardware file does not automatically contain all bootloader settings.
6. Preserve the installation's state versions. For a new home, choose an appropriate Home Manager baseline. The repository's `26.05` values do not need to increase when the OS or packages are updated.
7. Review user metadata in `modules/users/kaede.nix`, the selected record and hostname in `modules/hosts/syrup.nix`, the hardware composition in `modules/bundles/hardware-syrup.nix`, AMD/NVIDIA configuration and PCI addresses, kernel in `modules/system/boot.nix`, ASUS/tablet devices, and monitor/wallpaper outputs in the Niri/DMS assets. Preserve installer-specific requirements such as secure boot where applicable.
8. Once the target configuration is correct, set `hardwareReady = true`. Do not deploy the synthetic disk fixture in `tests/evaluate.nix`.

The current `syrup` configuration uses UEFI GRUB with Catppuccin Mocha. For another target, use bootloader settings verified on that target rather than automatically copying `syrup`'s choice.

## Validate and prepare to boot

Run all currently exposed checks listed in the [validation guide](VALIDATION.md). Then, from the repository root on the target:

```bash
nix flake check --no-build path:.
sudo nixos-rebuild build --flake path:.#syrup
sudo nixos-rebuild boot --flake path:.#syrup
sudo reboot
```

Adjust `syrup` if the host output name changes. `build` builds the configuration without activation; `boot` prepares the generation for the next boot. These are steps for the user to run, not evidence that deployment has occurred.

Home Manager is integrated into the NixOS configuration. Do not run its activation package directly against a home on another OS merely to test the configuration.

## Checks after entering the desktop

- Check DankGreeter login/logout and lock/unlock with the system password.
- Check `systemctl --user status dms udiskie opentabletdriver`. DMS and udiskie are declared through Home Manager; the NixOS module provides the OpenTabletDriver user unit. Avoid duplicate instances.
- Alacritty and Kitty must follow `globals.defaultShell`: currently Nushell, with Fish still available. `Mod+T` and `xdg-terminal-exec --print-id` must follow `globals.defaultTerminal`, currently Kitty. Existing homes need the [one-time binding migration](CONFIGURATION.md#choosing-alacritty-or-kitty). Check Starship and a single Fastfetch greeting on interactive startup.
- Change DMS settings, wallpaper, terminal themes, and tablet area; confirm that GUI changes survive a rebuild. The default terminal application is managed by Nix, while terminal colors remain writable.
- Check Brave and WhatsApp Web, Discord, notifications, clipboard, file chooser, and screen sharing as needed.
- Check audio/microphone, Pavucontrol/EasyEffects, brightness, networking, Bluetooth, Niri shortcuts, and screenshots.
- Check supported ASUS features, CTL-472/area rotation, osu!lazer, NVIDIA offload, suspend/resume, and external displays. Do not run osu!'s built-in tablet driver alongside OTD if they compete for the device.

If the new generation causes problems, select the previous generation from the boot menu. NixOS rollback does not restore writable GUI data; see [configuration ownership](CONFIGURATION.md#writable-files-and-one-time-seeding).
