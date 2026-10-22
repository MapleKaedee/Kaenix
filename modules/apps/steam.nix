{ ... }:
{
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        protontricks.enable = true;
        # Make these tools available inside Steam's FHS environment as well.
        extraPackages = [
          pkgs.mangohud
          pkgs.gamescope
          pkgs.gamemode
        ];
      };

      # Optional nested compositor; keep Niri as the desktop session.
      programs.gamescope.enable = true;
      programs.gamemode.enable = true;
    };
}
