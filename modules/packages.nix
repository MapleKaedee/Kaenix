{ ... }:
{
  flake.modules.nixos.packages =
    # Explicit package lists. Program and service modules also install their own packages.
    {
      pkgs,
      globals,
      inputs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        # Desktop compatibility and applications.
        xwayland-satellite
        nautilus
        zed-editor
        chatgpt
        deepseek-harness

        # Git and command-line utilities.
        git
        gh
        curl
        wget
        codex
        nil
        nixd
      ];

      home-manager.users.${globals.username}.home.packages = with pkgs; [
        # DMS video wallpaper support.
        mpvpaper
        ffmpeg

        # Applications.
        discord
        obs-studio
        osu-lazer-bin
        spotify

        # Terminal multiplexer; start manually with tuios new.
        tuios

        # Gaming tools; Steam, Protontricks, Gamescope, and GameMode use the Steam feature.
        protonplus
        mangohud
        goverlay

        # Nix and Wayland tools.
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.kae
        nix-output-monitor
        nixfmt
        wl-clipboard

        # PipeWire mixer and effects; no EasyEffects service or preset.
        pavucontrol
        easyeffects
      ];

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        jetbrains-mono
      ];

      # Packages installed through feature modules (not a transitive dependency list):
      # - modules/apps/kitty.nix: Kitty.
      # - modules/apps/{alacritty,btop,brave,helix,steam,yazi}.nix:
      #   Alacritty, btop, Brave, Helix, Steam/steam-run, Protontricks,
      #   Gamescope, GameMode, and Yazi.
      # - modules/shell/{fish,nushell,common,fastfetch,git}.nix:
      #   Fish/autopair, Nushell, Starship/eza, Fastfetch, and Home Manager's Git.
      # - modules/desktop/{niri,mango,dms,theme}.nix: Niri, Mango, DMS/DankGreeter,
      #   DMS integrations, xdg-terminal-exec, and the Adwaita cursor package.
      # - modules/hardware/: NVIDIA, ASUS utilities, OpenTabletDriver,
      #   Bluetooth, and power management through their modules.
      # - modules/services/: audio, printing, automount, session integrations,
      #   and SCX schedulers.
      # - modules/system/: kernel, networking, Nix, and Home Manager infrastructure.
      # Keep enable flags and package selections alongside those configurations.
    };
}
