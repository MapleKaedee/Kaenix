# home-manager configuration entrypoint
{ globals, ... }:

{
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
