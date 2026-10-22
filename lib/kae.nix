{
  pkgs,
  hostname ? "syrup",
  repository ? "/home/kaede/Kaenix",
  commands ? { },
}:
let
  checkFormatter = pkgs.nixfmt-tree.override {
    settings.formatter.nixfmt.options = [ "--check" ];
  };
  settings = {
    inherit hostname repository;
    system = pkgs.stdenv.hostPlatform.system;
    commands = {
      nix = "${pkgs.nix}/bin/nix";
      nom = "${pkgs.nix-output-monitor}/bin/nom";
      rebuild = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
      collectGarbage = "${pkgs.nix}/bin/nix-collect-garbage";
      formatterCheck = "${checkFormatter}/bin/treefmt";
      sudo = "/run/wrappers/bin/sudo";
    }
    // commands;
  };
in
pkgs.writeScriptBin "kae" ''
  #!${pkgs.nushell}/bin/nu --no-config-file
  const KAE_CONFIG = ${builtins.toJSON settings}
  ${builtins.readFile ../scripts/kae.nu}
''
