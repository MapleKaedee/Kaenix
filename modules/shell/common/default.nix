{ globals, ... }:
{
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
