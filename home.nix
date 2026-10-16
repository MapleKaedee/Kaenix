# home-manager configuration entrypoint
{ globals, ... }:

{
  imports = [
    ./modules/home/apps-home.nix
    ./modules/home/fish-home.nix
    ./modules/home/kitty-home.nix
    ./modules/home/fastfetch-home.nix
    ./modules/home/seed-files.nix
    ./modules/home/cursor-home.nix
    ./modules/home/niri-home.nix
    ./modules/home/dms-home.nix
    ./modules/home/tablet-home.nix
    ./modules/home/automount-home.nix
  ];

  home.username = globals.username;
  home.homeDirectory = "/home/${globals.username}";

  home.stateVersion = globals.installation.homeStateVersion;
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  programs.home-manager.enable = true;
}
