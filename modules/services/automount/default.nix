{ globals, ... }:
{
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
