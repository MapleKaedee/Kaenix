{ pkgs, globals, ... }:
{
  environment.systemPackages = [
    pkgs.git
    pkgs.gh
  ];
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
