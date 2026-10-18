{ globals, ... }:
{
  hardware.opentabletdriver.enable = true;
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
