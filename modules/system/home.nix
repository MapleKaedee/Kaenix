{ ... }:
{
  flake.modules.nixos.home = { globals, ... }: {
    home-manager.users.${globals.username} =
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
      };
  };
}
