{ config, lib, pkgs, ... }:
let
  manifest = pkgs.writeText "kaenix-seed-files.json" (builtins.toJSON config.kaenix.seedFiles);
in
{
  options.kaenix.seedFiles = lib.mkOption {
    default = [ ];
    description = "Initial writable files, copied only when the home-relative target is absent.";
    type = lib.types.listOf (lib.types.submodule {
      options = {
        target = lib.mkOption { type = lib.types.str; };
        source = lib.mkOption { type = lib.types.path; };
      };
    });
  };
  config.home.activation.kaenixSeedFiles = lib.hm.dag.entryBetween
    [ "reloadSystemd" ] [ "linkGeneration" ] ''
      run ${pkgs.python3}/bin/python3 ${../../scripts/seed-files.py} \
        --home ${lib.escapeShellArg config.home.homeDirectory} \
        --manifest ${manifest}
    '';
}
