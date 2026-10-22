# Evaluation fixture only. NEVER deploy this synthetic disk/boot configuration.
# nix eval --impure --json --expr 'import ./tests/evaluate.nix { flake = builtins.getFlake ("path:" + toString ./.); }'
{
  flake,
  defaultShell ? "nushell",
  defaultTerminal ? "alacritty",
}:
let
  original = flake.nixosConfigurations.syrup;
  fixture = original.extendModules {
    specialArgs.globals = {
      username = "kaede";
      hostname = "syrup";
      inherit defaultShell defaultTerminal;
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
assert
  hm.programs.kitty.settings.shell
  == "${fixture.pkgs.lib.getExe cfg.users.users.kaede.shell} --login";
assert
  hm.programs.alacritty.settings.terminal.shell.program
  == fixture.pkgs.lib.getExe cfg.users.users.kaede.shell;
assert hm.programs.alacritty.settings.terminal.shell.args == [ "--login" ];
assert cfg.users.users.kaede.shell.outPath == fixture.pkgs.${defaultShell}.outPath;
assert hm.programs.kitty.enable && hm.programs.alacritty.enable;
assert hm.programs.btop.enable;
assert
  hm.programs.btop.settings == {
    color_theme = "TTY";
    theme_background = false;
  };
assert hm.programs.helix.enable && hm.programs.helix.defaultEditor;
assert hm.programs.helix.settings.theme == "base16_transparent";
assert hm.programs.helix.settings.editor.line-number == "relative";
assert hm.programs.helix.settings.editor.color-modes;
assert hm.home.sessionVariables.EDITOR == "hx" && hm.home.sessionVariables.VISUAL == "hx";
assert hm.programs.yazi.enable;
assert hm.programs.yazi.settings.mgr.sort_by == "natural";
assert hm.programs.yazi.settings.mgr.sort_dir_first;
assert hm.programs.yazi.shellWrapperName == "y";
assert hm.programs.yazi.enableFishIntegration && hm.programs.yazi.enableNushellIntegration;
assert builtins.all
  (pkg: builtins.any (installed: installed.outPath == pkg.outPath) hm.home.packages)
  [
    hm.programs.alacritty.package
    hm.programs.kitty.package
    hm.programs.btop.package
    hm.programs.helix.package
    hm.programs.yazi.package
    fixture.pkgs.tuios
  ];
assert cfg.environment.sessionVariables.TERMINAL == defaultTerminal;
assert hm.xdg.terminal-exec.enable;
assert
  hm.xdg.terminal-exec.settings.default == [
    (if defaultTerminal == "alacritty" then "Alacritty.desktop" else "kitty.desktop")
  ];
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
  terminal = cfg.environment.sessionVariables.TERMINAL;
  services = builtins.attrNames hm.systemd.user.services;
}
