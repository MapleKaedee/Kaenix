{ pkgs, globals, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = globals.username;
      email = "maplemepuruu@gmail.com";
    };
  };
  programs.brave.enable = true;
  home.sessionVariables.BROWSER = "brave";
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
    };
  };
  home.packages = [ pkgs.osu-lazer-bin ];
}
