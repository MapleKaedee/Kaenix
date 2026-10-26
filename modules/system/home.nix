{ ... }:
{
  flake.modules.nixos.home = { globals, ... }: {
    home-manager.users.${globals.username} =
      { config, globals, ... }:

      {
        home.username = globals.username;
        home.homeDirectory = "/home/${globals.username}";

        home.stateVersion = globals.installation.homeStateVersion;
        xdg.enable = true;
        xdg.userDirs = {
          enable = true;
          createDirectories = true;
        };

        # Retain generated MIME defaults as a baseline; DMS owns the live file.
        xdg.configFile."mimeapps.list".enable = false;
        xdg.dataFile."applications/mimeapps.list".enable = false;
        kaenix.seedFiles = [
          {
            target = ".config/mimeapps.list";
            source = config.xdg.configFile."mimeapps.list".source;
          }
        ];

        programs.home-manager.enable = true;
      };
  };
}
