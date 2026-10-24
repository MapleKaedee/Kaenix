# Kaenix validation

Updated: 24 October 2026. Run commands from the repository root. The commands and coverage below follow the repository configuration; previously executed results are recorded in the [changelog](../CHANGELOG.md).

## Evidence scope

| Check type | Supported conclusion |
| --- | --- |
| Code inspection/evaluation | Options and derivations can be evaluated; this does not prove that packages have been built or changes are active |
| Check/package build | The requested check or package is available; this is not a full system build or GUI test |
| Activation | A generation has been applied to the system/user; this requires separate evidence |
| Runtime | A specific function was tested on the target session/device; state what was tested and when |

`nix flake check --no-build` evaluates checks without building them. `tests/evaluate.nix` replaces disk/boot settings with a synthetic fixture; do not deploy its output to a machine.

## Repeatable checks

```bash
# Evaluate flake outputs without building checks or activating anything
nix flake check --no-build path:.

# Build all nine checks in their respective Nix environments
nix build --no-link path:.#checks.x86_64-linux.kae path:.#checks.x86_64-linux.terminal-apps path:.#checks.x86_64-linux.terminals path:.#checks.x86_64-linux.shells path:.#checks.x86_64-linux.seed-files path:.#checks.x86_64-linux.seed-integration path:.#checks.x86_64-linux.niri-config path:.#checks.x86_64-linux.mango-config path:.#checks.x86_64-linux.mpv-config

# Evaluate the fixture with all four terminal and shell combinations
nix eval --impure --json --expr 'let flake = builtins.getFlake ("path:" + toString ./.); in builtins.map (selection: import ./tests/evaluate.nix ({ inherit flake; } // selection)) [ { defaultShell = "nushell"; defaultTerminal = "alacritty"; } { defaultShell = "fish"; defaultTerminal = "alacritty"; } { defaultShell = "nushell"; defaultTerminal = "kitty"; } { defaultShell = "fish"; defaultTerminal = "kitty"; } ]'

# Evaluate bundle ownership/reachability, typed preferences, output wiring, readiness, and host-free discovery
nix eval --impure --json --no-update-lock-file --file tests/ownership.nix

# Check whitespace in tracked changes
git diff --check
```

| Check | Coverage |
| --- | --- |
| `kae` | Packaged Nu entry point, isolated user configuration, command dispatch/arguments/cwd, all/selected input update dispatch, informative help through both help forms, check discovery, errors and exit codes, generation retention and privilege boundaries with stubs; pinned formatter checks and writes only in disposable fixtures |
| `terminals` | Home Manager's generated Alacritty TOML and Kitty config, direct login-shell startup, writable theme import, XDG selection of both desktop entries, and argument forwarding |
| `terminal-apps` | Generated btop, Helix, and Yazi configuration values plus `--version` smoke tests for all three pinned packages |
| `mpv-config` | English UI locale, video MIME defaults, parsing/script startup on pinned mpv, shaders/presets, writable volume/resume state, deployed FFmpeg `libplacebo` availability, and SDR thumbnails from two instances in a temporary home without a display |
| `shells` | Fish/Nushell parsing and startup, login environment, Starship, aliases, Yazi's `y` wrapper in both shells, and interactive/noninteractive greetings |
| `seed-files` | Copy-once helper, preservation of user changes, and path/symlink protections |
| `seed-integration` | Contents of all 17 Home Manager seeds, JSON, canonical DMS paths/theme baseline, preservation of DMS settings/plugins/session/theme in a migrated home with compatibility symlinks, and preservation of edited DMS settings and Alacritty themes when the helper runs again |
| `niri-config` | Base KDL validation without DMS fragments and with baseline DMS fragments |
| `mango-config` | Pinned package session-target presence and generated Mango configuration parsing |

Seed checks provide Python through Nix; a global Python installation is unnecessary. Home Manager's seed activation also uses the Nix-provided interpreter. Running unit tests directly with `python3` is only an alternative when an interpreter is available.

After activation, `kae check` runs lock-preserving flake evaluation and `kae test [checks...]` builds all or selected checks; see the [command guide](CONFIGURATION.md#kaenix-management-with-kae). The `kae` check uses stubbed Nix, nom, rebuild, and sudo commands, including for `kae update`. It verifies that `kae build` invokes nom for the explicit configured system target with lockfile protection and no sudo, while `kae switch` retains rebuild and elevation. It also verifies that update requests allow lockfile writes without sudo or follow-up operations, and that help explains command variants without invoking external commands. It does not update real dependencies, activate a generation, collect garbage, optimize the store, or build the full system.

For formatting changes, use the formatter output on relevant files; `nix fmt` writes changes. The `path:.` reference includes new unstaged files, while a regular Git flake reference requires them to be tracked.

## Dendritic migration comparisons

For a full feature migration, bundle composition or shared host-wiring changes, or changes to the flake-parts/import-tree foundation, record derivation paths before editing and after migration. Routine individual feature registrations or edits use evaluation, formatting, and the affected-feature checks; also inspect their registration, single bundle owner, and host reachability. Use the same existing input revisions for migration comparisons and verify the baseline/current lockfiles remain identical. Capture the system/default output, Home Manager activation, management package, formatter, and every check:

```bash
nix eval --impure --json --no-update-lock-file --option allow-import-from-derivation false --expr '
  let
    flake = builtins.getFlake ("path:" + toString ./.);
    host = flake.nixosConfigurations.syrup;
  in {
    system = host.config.system.build.toplevel.drvPath;
    default = flake.packages.x86_64-linux.default.drvPath;
    home = host.config.home-manager.users.kaede.home.activationPackage.drvPath;
    kae = flake.packages.x86_64-linux.kae.drvPath;
    formatter = flake.formatter.x86_64-linux.drvPath;
    checks = builtins.mapAttrs (_: check: check.drvPath) flake.checks.x86_64-linux;
  }'
```

Also compare all four shell/terminal fixture results using the command above under [repeatable checks](#repeatable-checks). Run all nine existing checks for an infrastructure migration. Inspect declared edges before Nix import deduplication: require exactly 43 registrations, the ordered seven project selections in the host, exact ordered bundle memberships, and no duplicate selection paths. All 37 leaf registrations must be reachable once: 36 through their single bundle owner and `packages` directly. `tests/ownership.nix` checks these graph invariants and rejects duplicate bundle selections, direct leaf selections, repeated members, and nested bundles, alongside the existing ownership contracts. Inspect bundle source separately to confirm that it contains imports only, without settings, options, or captured globals.

Confirm that loading module definitions, including bundles, the typed user schema, and metadata but excluding `modules/hosts/syrup.nix` and `modules/outputs.nix`, creates no hosts. Evaluate all four supported shell/terminal metadata combinations and reject invalid values through the typed `kaenix.users` options; separately confirm all four lower-level globals fixture overrides remain effective. Exercise the readiness assertion with `installation/installation.nix` data overridden in a disposable fixture, never by editing the real installation or bypassing the deployment guard. Compare evaluated system/user/font package selections, generated file contents and priorities/precedence, and seed manifests before and after migration; require unique seed targets and unchanged contents. Test preservation of all 17 edited seed files in disposable homes, never the real home.

Matching derivations establish equality for those generated outputs. Investigate differing paths with `nix derivation show` before accepting a refactor. Module reordering can change seed-list order and consequently manifest, activation, dependent system, and `seed-integration` derivations. Trace each difference to ordering or a substantive declaration change; compare seed manifests by target and content, package selections by their intended scope, and generated shell/terminal configurations. Do not assume every changed path is incidental or claim byte-identical outputs when order differs. Record which check results were freshly executed and which were reused from the store or substituted. These checks do not build or activate the full system or test the desktop session.

Global PipeWire tuning has no dedicated flake check. Evaluate the flake and ownership fixture, inspect the locked nix-gaming module and nixpkgs follows relationship, and build the generated PipeWire configuration package referenced by `environment.etc.pipewire.source`. Inspect its PipeWire, Pulse, and client `99-lowlatency.conf` files for the configured buffering values and upstream realtime/resampling defaults. Evaluate an explicitly disabled variant and verify these drop-ins disappear while base audio and RTKit remain enabled; confirm optional ALSA device overrides stay disabled. Check that the ordinary osu! package appears once, retains its executable/entry/MIME associations, and no custom low-latency launcher or desktop entry is generated. Follow the [global audio runtime and recovery guidance](CONFIGURATION.md#global-low-latency-tuning) after explicitly requested activation/restart; earlier server-forced measurements do not validate the global policy, and an exact 64-sample graph is not guaranteed.

## Local validation skill

Steam gaming has no dedicated headless game check. For changes to its feature or package list, evaluate the flake and inspect Steam/Protontricks/Gamescope/GameMode enablement, the GameMode user service, 32-bit graphics/audio, controller permissions, PRIME offload, and the unchanged firewall defaults. Build the configured Steam, Protontricks, and GameMode packages plus the pinned ProtonPlus, MangoHud, Gamescope, and GOverlay packages without activation. Inspect Steam's FHS environment for the gaming commands and GameMode's 32/64-bit preload libraries. Follow the [gaming runtime checklist](steam.md#runtime-verification) after activation; package availability does not prove that a game or overlay works in Niri.

Use [Kaenix Validate](../.agents/skills/kaenix-validate/SKILL.md), for example `$kaenix-validate validate Kaenix changes`, to select checks for the requested scope. The skill contains its procedure and action boundaries; dated results are in the [changelog](../CHANGELOG.md).

## Reviewing changes

Use [Kaenix Review](../.agents/skills/kaenix-review/SKILL.md), for example `$kaenix-review review current Kaenix changes`, for read-only correctness and migration review. The skill defines scope selection, findings, and routing for requested fixes. Neither a review with no findings nor passing checks proves runtime correctness.

For documentation and comment reviews, use the [documentation checklist](../.agents/skills/kaenix-review/SKILL.md#documentation-and-comment-checklist) in the review skill.

## Agent behavioral scenarios

The [agent scenario guide](../tests/agents/README.md) and its synthetic fixtures cover agent decisions about Kaenix ownership, review boundaries, writable seeds, package placement, validation, and documentation evidence. They complement skill structure and link checks; they are not Nix configuration checks. Select cases affected by a decision change, and keep wording-only checks static. Model trials require isolated sessions and follow the guide's protocol; dated results are in the changelog.

The validation skill loads context according to the requested scope; documentation
and skill checks need Nix implementation only when a claim or dependency requires
it. B09 exercises documentation-only context selection; B10–B12 cover partial
staging, root lock-graph research, and exact-pin updates respectively.

## Build failure diagnosis

Use [Kaenix Build Debug](../.agents/skills/kaenix-build-debug/SKILL.md), for example `$kaenix-build-debug diagnose this Kaenix build failure`, for evaluation/build faults. The skill defines reproduction and requested-fix procedures; diagnosis alone stays read-only and does not authorize activation.

## Runtime problem diagnosis

Use [Kaenix Runtime Debug](../.agents/skills/kaenix-runtime-debug/SKILL.md), for example `$kaenix-runtime-debug diagnose why screen sharing fails in my Niri session`, for live desktop, service, or device faults. The skill owns the diagnostic procedure and requested-fix boundaries. Live changes require separate authorization; conclusions depend on actual session/device access.

## Repository configuration and the active system

A configuration that evaluates successfully is not automatically the active generation. Inspect `/run/current-system` separately when comparing the active generation with the repository. Evaluation/build results do not prove activation or runtime testing.

The user can build the entire system with `sudo nixos-rebuild build --flake path:.#syrup`. For routine changes, follow the README's activation workflow. For reinstallation or another machine, use the [migration guide](MIGRATION.md).

Login/lock, Kitty appearance, notifications, audio, screen sharing, tablet, GPU/offload, suspend, and external displays still require separate runtime tests. Passing build checks does not prove that all these functions work.
