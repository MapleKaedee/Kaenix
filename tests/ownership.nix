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
  expectedBundles = {
    core = [
      "boot"
      "networking"
      "base"
      "users"
      "nix"
      "seed-files"
      "home-manager"
      "home"
    ];
    workstation = [
      "niri"
      "dms"
      "theme"
      "audio"
      "session"
      "printing"
      "automount"
    ];
    terminal = [
      "default-shell"
      "fish"
      "nushell"
      "common"
      "fastfetch"
      "git"
      "alacritty"
      "kitty"
      "btop"
      "helix"
      "yazi"
    ];
    applications = [
      "brave"
      "mpv"
    ];
    gaming = [ "steam" ];
    hardware-syrup = [
      "nvidia"
      "asus"
      "power"
      "tablet"
      "bluetooth"
      "scx"
    ];
  };
  expectedSelections = [
    "core"
    "packages"
    "workstation"
    "terminal"
    "applications"
    "gaming"
    "hardware-syrup"
  ];
  expectedLeaves = lib.sort builtins.lessThan (
    [ "packages" ] ++ lib.concatLists (builtins.attrValues expectedBundles)
  );
  expectedRegistrations = lib.sort builtins.lessThan (
    expectedLeaves ++ builtins.attrNames expectedBundles
  );
  projectPrefix = "${flake.outPath}/flake.nix#modules.nixos.";
  # Stop at the next project registration. Skip only its same-name wrappers;
  # graph retains declared imports before the module system deduplicates them.
  frontier =
    owner: nodes:
    lib.concatMap (
      node:
      let
        name =
          if lib.hasPrefix projectPrefix node.file then
            builtins.unsafeDiscardStringContext (lib.removePrefix projectPrefix node.file)
          else
            null;
      in
      if name != null && name != owner then [ { inherit name node; } ] else frontier owner node.imports
    ) nodes;
  inspectComposition =
    host:
    let
      selected = frontier null host.graph;
      bundles = builtins.filter (edge: builtins.hasAttr edge.name expectedBundles) selected;
      children = edge: frontier edge.name edge.node.imports;
      membership = builtins.listToAttrs (
        map (edge: {
          name = edge.name;
          value = map (child: child.name) (children edge);
        }) bundles
      );
      leaves =
        builtins.filter (edge: !(builtins.hasAttr edge.name expectedBundles)) selected
        ++ lib.concatMap children bundles;
      names = map (edge: edge.name) leaves;
    in
    {
      selections = map (edge: edge.name) selected;
      inherit membership;
      valid =
        map (edge: edge.name) selected == expectedSelections
        && membership == expectedBundles
        && lib.sort builtins.lessThan names == expectedLeaves
        && builtins.length (lib.unique names) == builtins.length names
        && builtins.all (edge: children edge == [ ]) leaves;
    };
  composition = inspectComposition flake.nixosConfigurations.syrup;
  duplicate = flake.nixosConfigurations.syrup.extendModules {
    modules = [ flake.modules.nixos.workstation ];
  };
  directLeaf = flake.nixosConfigurations.syrup.extendModules {
    modules = [ flake.modules.nixos.niri ];
  };
  repeatedLeaf = make (
    { config, ... }: { flake.modules.nixos.workstation.imports = [ config.flake.modules.nixos.niri ]; }
  );
  nestedBundle = make (
    { config, ... }: { flake.modules.nixos.workstation.imports = [ config.flake.modules.nixos.core ]; }
  );
  guards = builtins.filter (
    item: !item.assertion && lib.hasPrefix "kaenix: replace installation/" item.message
  ) notReady.config.assertions;
in
assert builtins.attrNames flake.modules.nixos == expectedRegistrations;
assert composition.valid;
assert !(inspectComposition duplicate).valid;
assert !(inspectComposition directLeaf).valid;
assert !(inspectComposition repeatedLeaf.nixosConfigurations.syrup).valid;
assert !(inspectComposition nestedBundle.nixosConfigurations.syrup).valid;
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
  composition = { inherit (composition) selections membership; };
  invalidCompositionsRejected = true;
  discoveryWithoutHost = true;
  renamedUserAndOutputs = true;
  unsupportedPreferencesRejected = true;
  installationReadinessGuard = true;
}
