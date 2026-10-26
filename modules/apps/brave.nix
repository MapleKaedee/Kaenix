{ ... }:
{
  flake.modules.nixos.brave =
    { globals, ... }:
    {
      home-manager.users.${globals.username} =
        { ... }:
        {
          programs.brave.enable = true;
          xdg.mimeApps = {
            enable = true;
            defaultApplications = {
              "text/html" = [ "brave-browser.desktop" ];
              "x-scheme-handler/http" = [ "brave-browser.desktop" ];
              "x-scheme-handler/https" = [ "brave-browser.desktop" ];
            };
          };
        };
    };
}
