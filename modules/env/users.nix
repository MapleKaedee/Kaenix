# System user account and default shell
{ pkgs, globals, ... }:
{
  users.users.${globals.username} = {
    isNormalUser = true;
    description = globals.username;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
