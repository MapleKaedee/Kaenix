{ ... }:
{
  flake.modules.nixos.fish =
    { pkgs, globals, ... }:
    {
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];
      home-manager.users.${globals.username} =
        { pkgs, ... }:
        {
          programs.fish = {
            enable = true;
            shellAliases.ls = "eza --icons --group-directories-first -1";
            functions.fish_greeting = "${pkgs.fastfetch}/bin/fastfetch";
            plugins = [
              {
                name = "autopair";
                src = pkgs.fishPlugins.autopair.src;
              }
            ];
          };
        };
    };
}
