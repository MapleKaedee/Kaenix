{ globals, ... }:
{
  home-manager.users.${globals.username} =
    { ... }:
    {
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
    };
}
