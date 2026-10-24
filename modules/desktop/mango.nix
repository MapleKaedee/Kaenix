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

          systemd.user.targets.mango-session.Unit = {
            Description = "Mango Wayland session";
            Requires = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
            Wants = [ "dms.service" ];
          };

          systemd.user.services.dms.Unit.PartOf = [ "mango-session.target" ];
        };
    };
}
