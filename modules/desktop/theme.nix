{ ... }:
{
  flake.modules.nixos.theme =
    { globals, ... }:
    {
      environment.sessionVariables = {
        XCURSOR_THEME = "Adwaita";
        XCURSOR_SIZE = "30";
      };
      fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font Mono" ];
      home-manager.users.${globals.username} =
        # Cursor theme for the user
        { pkgs, ... }:
        {
          home.pointerCursor = {
            enable = true;
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita";
            size = 30;
            gtk.enable = true;
            x11.enable = true;
          };
        };
    };
}
