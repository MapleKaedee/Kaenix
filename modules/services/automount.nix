{ globals, ... }:
{
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  home-manager.users.${globals.username} =
    { ... }:

    {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "auto";
      };
    };
}
