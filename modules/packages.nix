# Explicit package lists. Program and service modules also install their own packages.
{ pkgs, globals, ... }:
{
  environment.systemPackages = [
    # Desktop compatibility and applications.
    pkgs.xwayland-satellite
    pkgs.nautilus
    pkgs.zed-editor
    pkgs.chatgpt

    # Git and command-line utilities.
    pkgs.git
    pkgs.gh
    pkgs.curl
    pkgs.wget
  ];

  home-manager.users.${globals.username}.home.packages = [
    # DMS video wallpaper support.
    pkgs.mpvpaper
    pkgs.ffmpeg

    # Applications.
    pkgs.discord
    pkgs.osu-lazer-bin
    pkgs.spotify

    # Nix and Wayland tools.
    pkgs.nix-output-monitor
    pkgs.nixfmt
    pkgs.wl-clipboard

    # PipeWire mixer and effects; no EasyEffects service or preset.
    pkgs.pavucontrol
    pkgs.easyeffects
  ];

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.jetbrains-mono
  ];

  # Packages installed through feature modules (not a transitive dependency list):
  # - modules/apps/{alacritty,brave,kitty,mpv}.nix: Alacritty, Brave, Kitty, and mpv.
  # - modules/shell/{fish,nushell,common,fastfetch,git}.nix:
  #   Fish/autopair, Nushell, Starship/eza, Fastfetch, and Home Manager's Git.
  # - modules/desktop/{niri,dms,theme}.nix: Niri, DMS/DankGreeter,
  #   DMS integrations, xdg-terminal-exec, and the Adwaita cursor package.
  # - modules/hardware/: NVIDIA, ASUS utilities, OpenTabletDriver,
  #   Bluetooth, and power management through their modules.
  # - modules/services/: audio, printing, automount, and session integrations.
  # - modules/system/: kernel, networking, Nix, and Home Manager infrastructure.
  # Keep enable flags and package selections alongside those configurations.
}
