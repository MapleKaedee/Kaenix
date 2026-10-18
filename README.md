# Kaenix

My personal [NixOS](https://nixos.org/) configuration, built with Flakes and Home Manager for **syrup**.
[Repository](https://github.com/MapleKaedee/Kaenix) · [Getting started](#getting-started)

This configuration targets my installed `syrup` machine. [installation.nix](installation.nix) has `hardwareReady = true` and configures systemd-boot; both state versions remain `26.05`. Review the hardware and installation settings before using it on another installation. Repository changes still need a rebuild to become active.

## Host

| Setting | Target |
| --- | --- |
| Hostname / flake output | `syrup` / `nixosConfigurations.syrup` |
| User | `kaede` |
| Platform | `x86_64-linux` |
| Package source | `nixos-unstable`, pinned in `flake.lock` |
| Kernel | CachyOS kernel through Chaotic-Nyx |
| Graphics | Radeon 680M for the desktop; RTX 3060 Mobile through NVIDIA PRIME offload |
| Time zone | `Asia/Jakarta` |

The GPU PCI addresses and desktop preferences are specific to this machine. Adapt them along with the user and host settings when using this repository as a reference.

## Desktop components

| Component | Choice |
| --- | --- |
| Wayland compositor | Niri + Xwayland Satellite |
| Desktop shell | DankMaterialShell (DMS) |
| Login screen | DankGreeter |
| Terminal | Kitty |
| Shell / prompt | Nushell (default) + Fish, with shared Starship |
| Command-line tools | eza, Fastfetch, Fish autopair |
| Nix build output | nix-output-monitor (`nom`) |
| Nix formatting | nixfmt (`nixfmt`, `nix fmt`) |
| Browser | Brave |
| Messaging | WhatsApp Web in Brave / Discord |
| Editor / file manager | Zed / Nautilus |
| Theme / fonts | Catppuccin Mocha with Mauve; JetBrains Mono and its Nerd Font variant |
| Audio / networking | PipeWire / NetworkManager |
| Audio controls / effects | Pavucontrol / EasyEffects |
| ASUS controls | asusd, asusctl, and ROG Control Center |
| Tablet / game | OpenTabletDriver / osu!lazer |
| DMS plugins | catWidget and mpvpaper, pinned to specific commits |

## Repository layout

```text
.
├── flake.nix                    # Inputs and the syrup NixOS configuration
├── flake.lock                   # Pinned dependency revisions
├── installation.nix             # Installation guard, bootloader, state versions
├── hardware-configuration.nix    # Hardware and mounts for syrup
├── configuration.nix            # System entry point
├── home.nix                     # Home Manager entry point
├── modules/
│   ├── default.nix              # Explicit category imports
│   ├── desktop/                 # Niri, DMS, fonts, and cursor theme
│   ├── shell/                   # Fish, Nushell, prompt, Git, and CLI tools
│   ├── apps/                    # Browser, terminal, messaging, media, and other apps
│   ├── hardware/                # NVIDIA, ASUS, power, tablet, and Bluetooth
│   ├── services/                # Audio, printing, automount, and session services
│   └── system/                  # Base settings, users, Nix, and Home Manager support
├── config/                      # Configuration assets and initial GUI settings
├── collection/                  # Wallpapers, including the mpvpaper video
├── scripts/                     # Writable-default initialization helper
└── tests/                       # Seed tests, Niri validation, evaluation fixture
```

Modules are grouped by function, following the organizational approach of [hlissner/dotfiles](https://github.com/hlissner/dotfiles). Each category explicitly imports its feature directories. A feature's `default.nix` is a NixOS module; an optional adjacent `home.nix` contains Home Manager configuration and is registered through `home-manager.users.${globals.username}.imports`.

For example, `modules/desktop/niri/default.nix` enables the compositor and imports `home.nix` for its user configuration. The root `home.nix` keeps shared user identity and XDG settings. Writable-file initialization lives in `modules/system/home-manager/seed-files.nix`; assets remain in `config/`. Features are selected through imports, with no custom enable switches or recursive discovery.

To add a feature, create its directory under the relevant category and add it to that category's imports. Use `path:.` for local flake checks until new files are staged in Git.

Local `docs/` and `CHANGELOG.md` are intentionally ignored by Git. Include them, uncommitted files, and `.git/` when backing up the complete working directory.

## Getting started

### Routine use on syrup

From the repository root on the configured machine, evaluate and build before activating changes:

```bash
nix flake check --no-build path:.
sudo nixos-rebuild build --flake path:.#syrup
sudo nixos-rebuild switch --flake path:.#syrup
```

`build` does not activate the configuration; `switch` does. For bootloader, kernel, or graphics changes, use `sudo nixos-rebuild boot --flake path:.#syrup` and reboot when ready instead of activating during the current desktop session. Home Manager is included in the NixOS rebuild.

### Fresh installation or another machine

Start from a working NixOS installation with Git and flakes enabled:

```bash
git clone https://github.com/MapleKaedee/Kaenix.git
cd Kaenix
```

Before deploying this checkout to a new target:

1. Back up important data.
2. Set `hardwareReady = false` while adapting the configuration, then replace `hardware-configuration.nix` with the generated file from the target installation.
3. Copy the target's bootloader settings and preserve the appropriate initial system and Home Manager state versions in `installation.nix`. Do not raise state versions merely to match an OS or package update.
4. Review the user/host settings, GPU PCI addresses, kernel, ASUS/tablet settings, and monitor outputs. Set `hardwareReady = true` after the target settings are ready.

Once the installation settings are ready, build and prepare the next boot:

```bash
nix flake check --no-build path:.
sudo nixos-rebuild build --flake path:.#syrup
sudo nixos-rebuild boot --flake path:.#syrup
sudo reboot
```

Replace `syrup` if you rename the host output. The checked-in state versions are installation baselines, not the running OS version.

## Validation

Evaluate with `nix flake check --no-build path:.`. To build all four checks:

```bash
nix build --no-link path:.#checks.x86_64-linux.shells path:.#checks.x86_64-linux.seed-files path:.#checks.x86_64-linux.seed-integration path:.#checks.x86_64-linux.niri-config
```

These cover shell startup/login integration, writable seed behavior, and Niri configuration. The seed checks provide their own Python interpreter through Nix. `tests/evaluate.nix` is a synthetic disk/boot fixture for evaluation only; never deploy it. Evaluation and check builds do not establish that changes are active or that login, audio, screen sharing, tablet, GPU, or suspend work in a desktop session.

## Monitoring builds

Home Manager installs `nix-output-monitor` from the pinned nixpkgs input. After rebuilding, use `nom build` explicitly to display build progress, downloads, and the dependency tree. For example, from this repository:

```bash
nom build --no-link path:.#checks.x86_64-linux.shells
```

The package also provides `nom-build` and `nom-shell` for the legacy Nix commands. These commands are available from Nushell and Fish. Monitoring `nixos-rebuild` requires piping its logs to `nom` separately; see the [upstream usage guide](https://github.com/maralorn/nix-output-monitor#running). The regular Nix commands are not aliased or replaced.

## Formatting Nix code

Home Manager installs `nixfmt` from the pinned nixpkgs input. After rebuilding, the `nixfmt` command is available from Nushell and Fish. The flake also provides `nixfmt-tree` as its formatter, so `nix fmt` works before system activation. Run these commands from the repository root:

```bash
# Format one file
nixfmt modules/shell/nix/home.nix

# Format all Nix files in the project
nix fmt

# Format only selected files
nix fmt -- flake.nix modules/shell/nix/home.nix
```

These commands write formatting changes to files. Formatting is explicit; no Git hooks or editor format-on-save settings are installed. See the [upstream documentation](https://github.com/NixOS/nixfmt#installation).

## Messaging

Home Manager installs the official Discord client from the pinned nixpkgs input. After rebuilding, open **Discord** from the DMS launcher or run `discord` from a terminal. Sign in through its application window.

For WhatsApp, open [WhatsApp Web](https://web.whatsapp.com/) in Brave. Open **Linked devices** in WhatsApp on your phone, choose **Link a device**, and scan the QR code shown in the browser. No separate WhatsApp client is installed.

Accounts and application preferences remain writable user data. No autostart entries or Discord modifications are added. After rebuilding, verify the Discord launcher entry, login, notifications, and audio in your desktop session.

## References and inspiration

- [Ryan4Yin's nix-config](https://github.com/ryan4yin/nix-config) — inspiration for the README structure.
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) — learning and configuration reference.

The revisions in `flake.lock` determine the configuration interfaces used here; upstream documentation may describe newer versions.
