{ ... }:
{
  flake.modules.nixos.nix =
    { ... }:
    {
      nixpkgs.config.allowUnfree = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      nix.settings.auto-optimise-store = true;
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
}
