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
        { ... }:
        {
          xdg.configFile."mango/config.conf".text = builtins.readFile ../../config/mango/config.conf;

          systemd.user.services.dms = {
            Install.WantedBy = [ "mango-session.target" ];
            Unit.PartOf = [ "mango-session.target" ];
          };
        };
    };
}
