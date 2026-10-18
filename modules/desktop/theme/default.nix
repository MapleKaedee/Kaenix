{ pkgs, globals, ... }:
{
  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "30";
  };
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
