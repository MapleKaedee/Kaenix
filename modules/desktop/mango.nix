{ ... }:
{
  flake.modules.nixos.mango =
    {
      globals,
      ...
    }:
    {
      programs.mango.enable = true;

      home-manager.users.${globals.username} =
        { lib, ... }:
        {
          xdg.configFile."mango/config.conf".text = builtins.readFile ../../config/mango/config.conf;

          kaenix.seedFiles = map (name: {
            target = ".config/mango/dms/${name}";
            source = ../../config/mango/dms + "/${name}";
          }) (lib.attrNames (builtins.readDir ../../config/mango/dms));

          systemd.user.services.dms = {
            Install.WantedBy = [ "mango-session.target" ];
            Unit = {
              After = [ "mango-session.target" ];
              PartOf = [ "mango-session.target" ];
            };
          };
        };
    };
}
