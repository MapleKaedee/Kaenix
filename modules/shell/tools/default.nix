{ pkgs, globals, ... }:
{
  environment.systemPackages = [
    pkgs.curl
    pkgs.wget
  ];
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
