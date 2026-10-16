{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellAliases.ls = "eza --icons --group-directories-first -1";
    functions.fish_greeting = "${pkgs.fastfetch}/bin/fastfetch";
    plugins = [{ name = "autopair"; src = pkgs.fishPlugins.autopair.src; }];
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../../config/fish/starship.toml);
  };
  programs.eza.enable = true;
  programs.eza.enableFishIntegration = false;
}
