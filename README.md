# Kaenix

My personal [NixOS](https://nixos.org/) configuration.

> [!IMPORTANT]
> **Disclaimer:** _This is not a "community framework" or "NixOS distribution"._
> Please do not use it like one. It is an ongoing and experiment to
> feel out NixOS and the Nix language for my own purposes.
> It's better to use it as a reference, not as a drop-in replacement.

## Desktop components

| Component | Choice |
| --- | --- |
| Wayland compositor | Niri + Xwayland Satellite |
| Desktop shell | DankMaterialShell (DMS) |
| Login screen | DankGreeter |
| Terminal | Kitty (default) + Alacritty |
| Shell / prompt | Nushell (default) + Fish, with shared Starship |
| Command-line tools | eza, Fastfetch, Fish autopair, btop, Yazi |
| Terminal multiplexer | TUIOS (manual sessions with `tuios new`) |
| Nix formatting | nixfmt (`nixfmt`, `nix fmt`) |
| Browser | Brave |
| Editor | Zed + Helix (default CLI editor) |
| Media player | mpv |
| Gaming | Steam, Protontricks, Gamescope, GameMode |
| Theme | Catppuccin Mocha with Mauve |
| Fonts | JetBrains Mono and its Nerd Font variant |
| Audio / networking | PipeWire / NetworkManager |
| Audio controls / effects | Pavucontrol / EasyEffects |
| ASUS controls | asusd, asusctl, and ROG Control Center |

## Repository layout

```text
.
├── flake.nix                       # Inputs, caches, and module discovery
├── flake.lock                      # Pinned dependency revisions
├── AGENTS.md                       # Project instructions
├── CHANGELOG.md                    # Dated changes and validation results
├── README.md                       # Public overview and getting started
├── modules/
│   ├── hosts/syrup.nix             # Host identity, user selection, and composition
│   ├── users/kaede.nix             # Username, default shell, and default terminal
│   ├── bundles/                    # Six shallow, explicit feature compositions
│   ├── system/
│   │   ├── base.nix                # Locale, timezone, keyboard, and zram
│   │   ├── boot.nix                # Kernel and installation bootloader
│   │   ├── networking.nix          # NetworkManager
│   │   ├── nix.nix                 # Nix configuration
│   │   ├── users.nix               # User preference schema and account/groups
│   │   ├── home-manager.nix        # Home Manager integration
│   │   ├── home.nix                # Home identity, state version, and XDG defaults
│   │   └── seed-files.nix          # Writable GUI seed options and activation
│   ├── hardware/                   # NVIDIA, ASUS, power, tablet, and Bluetooth
│   ├── desktop/                    # Niri, DMS, fonts, and cursor theme
│   ├── shell/                      # Fish, Nushell, prompt, Git, and CLI tools
│   ├── apps/                       # Terminals, browser, editors, media, and Steam
│   ├── services/                   # Audio, printing, automount, session, and SCX
│   ├── packages.nix                # Explicit system, user, and font package lists
│   └── outputs.nix                 # System package, kae, formatter, and checks
├── installation/
│   ├── hardware-configuration.nix  # Generated hardware and mounts for syrup
│   └── installation.nix            # Readiness, bootloader, and state versions
├── lib/                            # Shared package helpers and kae packaging
├── config/                         # Configuration assets and initial GUI settings
├── collection/                     # Wallpapers, including the mpvpaper video
├── scripts/                        # kae, shell helpers, and writable-file seeding
├── tests/                          # Configuration checks and evaluation fixtures
├── docs/                           # Local configuration, migration, and validation guides
└── .agents/                        # Project-local agent skills
```
## Screenshots
![desktop](collection/desktop.png)

## Getting started

### Installation

```bash
git clone https://github.com/MapleKaedee/Kaenix.git
cd Kaenix
```

These steps adapt an already installed NixOS system. Before deploying this checkout to a new target:

1. Back up important data and keep a copy of the working installer configuration. Ensure the target account has a password.
2. Set `hardwareReady = false` in `installation/installation.nix` while adapting the configuration.
3. Replace `installation/hardware-configuration.nix` with the target's generated hardware configuration. Set the target's bootloader in `installation/installation.nix` and preserve its system and Home Manager state versions.
4. Review username, default shell, and default terminal in `modules/users/kaede.nix`. Review the selected user record and hostname in `modules/hosts/syrup.nix`, hardware selection in `modules/bundles/hardware-syrup.nix`, GPU PCI addresses, kernel choice, and Niri/DMS monitor outputs.
5. Set `hardwareReady = true` only after the target settings have been checked.

Once the installation settings and checks are ready, build and prepare the next boot:

```bash
nix flake check --no-build --no-update-lock-file path:.
sudo nixos-rebuild build --flake path:.#syrup
sudo nixos-rebuild boot --flake path:.#syrup
sudo reboot
```

Or if you want to rebuild and switch at the same time:

```bash
sudo nixos-rebuild switch --flake path:.#syrup
```

Use the selected host output name in place of `syrup` if you rename it.

## References and inspiration

- [Ryan4Yin's nix-config](https://github.com/ryan4yin/nix-config) — inspiration for the README structure.
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) — learning and configuration reference.
