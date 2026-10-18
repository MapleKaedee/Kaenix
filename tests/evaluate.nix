# Evaluation fixture only. NEVER deploy this synthetic disk/boot configuration.
# nix eval --impure --json --expr 'import ./tests/evaluate.nix { flake = builtins.getFlake ("path:" + toString ./.); }'
{
  flake,
  defaultShell ? "nushell",
}:
let
  original = flake.nixosConfigurations.syrup;
  fixture = original.extendModules {
    specialArgs.globals = {
      username = "kaede";
      hostname = "syrup";
      inherit defaultShell;
      installation = (import ../installation.nix) // {
        hardwareReady = true;
        bootLoader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = false;
        };
      };
    };
    modules = [
      ({ lib, ... }: {
        fileSystems = lib.mkForce {
          "/" = {
            device = "/dev/disk/by-label/kaenix-test-root";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-label/kaenix-test-efi";
            fsType = "vfat";
          };
        };
        swapDevices = lib.mkForce [ ];
      })
    ];
  };
  cfg = fixture.config;
  hm = cfg.home-manager.users.kaede;
in
assert cfg.hardware.nvidia.open;
assert cfg.hardware.nvidia.prime.offload.enable;
assert !cfg.hardware.nvidia.prime.sync.enable;
assert !hm.programs.dank-material-shell.managePluginSettings;
assert !(hm.xdg.configFile ? "DankMaterialShell/settings.json");
assert cfg.programs.fish.enable && cfg.programs.nushell.enable;
assert hm.programs.fish.enable && hm.programs.nushell.enable;
assert hm.programs.starship.enableFishIntegration && hm.programs.starship.enableNushellIntegration;
assert hm.programs.kitty.settings.shell == fixture.pkgs.lib.getExe cfg.users.users.kaede.shell;
assert cfg.users.users.kaede.shell.outPath == fixture.pkgs.${defaultShell}.outPath;
{
  systemDrv = cfg.system.build.toplevel.drvPath;
  homeDrv = hm.home.activationPackage.drvPath;
  versions = {
    niri = fixture.pkgs.niri.version;
    dms = hm.programs.dank-material-shell.package.version;
    kernel = cfg.boot.kernelPackages.kernel.version;
    nvidia = cfg.hardware.nvidia.package.version;
  };
  seedCount = builtins.length hm.kaenix.seedFiles;
  shell = cfg.users.users.kaede.shell.name;
  services = builtins.attrNames hm.systemd.user.services;
}
