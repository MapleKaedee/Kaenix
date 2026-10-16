{ pkgs, globals, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = globals.username;
        email = "maplemepuruu@gmail.com";
      };
      # gh cannot write helpers into Home Manager's read-only Git config.
      credential = {
        "https://github.com".helper = [ "" "${pkgs.gh}/bin/gh auth git-credential" ];
        "https://gist.github.com".helper = [ "" "${pkgs.gh}/bin/gh auth git-credential" ];
      };
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
  home.packages = [ pkgs.osu-lazer-bin pkgs.wl-clipboard ];
}
