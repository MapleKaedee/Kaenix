# Evaluation only: exercises metadata and host assembly without activation.
# nix eval --impure --json --file tests/ownership.nix
let
  flake = builtins.getFlake ("path:" + toString ../.);
  inherit (flake.inputs.nixpkgs) lib;
  make =
    extra:
    let
      self = flake // outputs;
      outputs =
        flake.inputs.flake-parts.lib.mkFlake
          {
            inputs = flake.inputs // {
              inherit self;
            };
          }
          {
            imports = [
              flake.inputs.flake-parts.flakeModules.modules
              (flake.inputs.import-tree ../modules)
              extra
              # Expose typed metadata only within this disposable evaluation.
              ({ config, ... }: { flake.testUser = config.kaenix.users.kaede; })
            ];
            systems = [ "x86_64-linux" ];
          };
    in
    outputs;
  profile = username: defaultShell: defaultTerminal: {
    kaenix.users.kaede = lib.mkForce { inherit username defaultShell defaultTerminal; };
  };
  selections = lib.cartesianProduct {
    defaultShell = [
      "nushell"
      "fish"
    ];
    defaultTerminal = [
      "alacritty"
      "kitty"
    ];
  };
  supported = map (
    selection:
    let
      outputs = make (profile "kaede" selection.defaultShell selection.defaultTerminal);
      host = outputs.nixosConfigurations.syrup;
      cfg = host.config;
      hm = cfg.home-manager.users.kaede;
    in
    assert cfg.users.users.kaede.shell.outPath == host.pkgs.${selection.defaultShell}.outPath;
    assert
      hm.programs.alacritty.settings.terminal.shell.program == lib.getExe cfg.users.users.kaede.shell;
    assert hm.programs.kitty.settings.shell == "${lib.getExe cfg.users.users.kaede.shell} --login";
    assert cfg.environment.sessionVariables.TERMINAL == selection.defaultTerminal;
    assert
      hm.xdg.terminal-exec.settings.default
      == [ (if selection.defaultTerminal == "kitty" then "kitty.desktop" else "Alacritty.desktop") ];
    assert hm.home.username == "kaede" && hm.home.homeDirectory == "/home/kaede";
    assert outputs.packages.x86_64-linux.default.drvPath == cfg.system.build.toplevel.drvPath;
    selection
  ) selections;
  renamed = make (profile "kaenix-fixture" "fish" "alacritty");
  renamedCfg = renamed.nixosConfigurations.syrup.config;
  renamedHome = renamedCfg.home-manager.users.kaenix-fixture;
  rejected =
    shell: terminal:
    !(builtins.tryEval (builtins.deepSeq (make (profile "kaede" shell terminal)).testUser true))
    .success;
  discovery = flake.inputs.flake-parts.lib.mkFlake { inputs = flake.inputs; } {
    imports = [
      flake.inputs.flake-parts.flakeModules.modules
      (
        (flake.inputs.import-tree.filter (
          path: !(lib.hasInfix "/hosts/" path) && !(lib.hasSuffix "/outputs.nix" path)
        ))
          ../modules
      )
    ];
    systems = [ "x86_64-linux" ];
  };
  notReady = flake.nixosConfigurations.syrup.extendModules {
    specialArgs.globals = {
      username = "kaede";
      hostname = "syrup";
      defaultShell = "nushell";
      defaultTerminal = "kitty";
      installation = (import ../installation/installation.nix) // {
        hardwareReady = false;
      };
    };
  };
  guards = builtins.filter (
    item: !item.assertion && lib.hasPrefix "kaenix: replace installation/" item.message
  ) notReady.config.assertions;
in
assert builtins.length (builtins.attrNames flake.modules.nixos) == 36;
assert (discovery.nixosConfigurations or { }) == { };
assert builtins.attrNames discovery.modules.nixos == builtins.attrNames flake.modules.nixos;
assert renamedCfg.users.users.kaenix-fixture.isNormalUser;
assert renamedHome.home.username == "kaenix-fixture";
assert renamedHome.home.homeDirectory == "/home/kaenix-fixture";
assert lib.hasInfix "/home/kaenix-fixture/Kaenix" renamed.packages.x86_64-linux.kae.text;
assert builtins.length guards == 1 && !(builtins.head guards).assertion;
assert rejected "bash" "kitty";
assert rejected "nushell" "xterm";
{
  inherit supported;
  registered = builtins.attrNames flake.modules.nixos;
  discoveryWithoutHost = true;
  renamedUserAndOutputs = true;
  unsupportedPreferencesRejected = true;
  installationReadinessGuard = true;
}
