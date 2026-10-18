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
}
