# System-wide installed packages
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    chatgpt
    git
    curl
    wget
    zed-editor
    nautilus
    gh
  ];
}
