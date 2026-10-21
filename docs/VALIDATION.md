# Kaenix validation

Updated: 21 October 2026. Run commands from the repository root. The commands and coverage below follow the repository configuration; previously executed results are recorded in the [changelog](../CHANGELOG.md).

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

# Build all six checks in their respective Nix environments
nix build --no-link path:.#checks.x86_64-linux.terminals path:.#checks.x86_64-linux.shells path:.#checks.x86_64-linux.seed-files path:.#checks.x86_64-linux.seed-integration path:.#checks.x86_64-linux.niri-config path:.#checks.x86_64-linux.mpv-config

# Evaluate the fixture with all four terminal and shell combinations
nix eval --impure --json --expr 'let flake = builtins.getFlake ("path:" + toString ./.); in builtins.map (selection: import ./tests/evaluate.nix ({ inherit flake; } // selection)) [ { defaultShell = "nushell"; defaultTerminal = "alacritty"; } { defaultShell = "fish"; defaultTerminal = "alacritty"; } { defaultShell = "nushell"; defaultTerminal = "kitty"; } { defaultShell = "fish"; defaultTerminal = "kitty"; } ]'

# Check whitespace in tracked changes
git diff --check
```

| Check | Coverage |
| --- | --- |
| `terminals` | Home Manager's generated Alacritty TOML, login shell, writable theme import, XDG selection of both desktop entries, and argument forwarding without opening windows |
| `mpv-config` | English UI locale, video MIME defaults, parsing/script startup on pinned mpv, shaders/presets, writable volume/resume state, and FFmpeg thumbnails from two instances in a temporary home without a display |
| `shells` | Fish/Nushell parsing and startup, login environment, Starship, aliases, and interactive/noninteractive greetings |
| `seed-files` | Copy-once helper, preservation of user changes, and path/symlink protections |
| `seed-integration` | Contents of all 17 Home Manager seeds, JSON, and preservation of edited DMS settings and Alacritty themes when the helper runs again |
| `niri-config` | Base KDL validation without DMS fragments and with baseline DMS fragments |

Seed checks provide Python through Nix; a global Python installation is unnecessary. Home Manager's seed activation also uses the Nix-provided interpreter. Running unit tests directly with `python3` is only an alternative when an interpreter is available.

For formatting changes, use the formatter output on relevant files; `nix fmt` writes changes. The `path:.` reference includes new unstaged files, while a regular Git flake reference requires them to be tracked.

## Local validation skill

Steam gaming has no dedicated headless game check. For changes to its feature or package list, evaluate the flake and inspect Steam/Protontricks/Gamescope/GameMode enablement, the GameMode user service, 32-bit graphics/audio, controller permissions, PRIME offload, and the unchanged firewall defaults. Build the configured Steam, Protontricks, and GameMode packages plus the pinned ProtonPlus, MangoHud, Gamescope, and GOverlay packages without activation. Inspect Steam's FHS environment for the gaming commands and GameMode's 32/64-bit preload libraries. Follow the [gaming runtime checklist](steam.md#runtime-verification) after activation; package availability does not prove that a game or overlay works in Niri.

Use [Kaenix Validate](../.agents/skills/kaenix-validate/SKILL.md), for example `$kaenix-validate validate Kaenix changes`, to select checks for the requested scope. The skill contains its procedure and action boundaries; dated results are in the [changelog](../CHANGELOG.md).

## Reviewing changes

Use [Kaenix Review](../.agents/skills/kaenix-review/SKILL.md), for example `$kaenix-review review current Kaenix changes`, for a read-only review of actionable defects, regressions, ownership conflicts, and migration gaps. The default scope combines staged, unstaged, and relevant untracked changes against `HEAD`; explicit files or comparison revisions take precedence. With no changes or specified scope, the skill asks what to review rather than starting an unsolicited audit.

Review complements validation by tracing behavior and affected consumers. Findings include concrete consequences, evidence, and file locations; targeted checks may help resolve uncertainty. The skill preserves repository files, the lockfile, Git index, and live settings, and directs explicitly requested fixes to the appropriate existing workflow. It does not write reports or documentation unless asked. No findings or passing checks do not prove runtime correctness.

## Build failure diagnosis

Use [Kaenix Build Debug](../.agents/skills/kaenix-build-debug/SKILL.md), for example `$kaenix-build-debug diagnose this Kaenix build failure`, to trace evaluation or build failures to actionable evidence. Diagnosis-only requests preserve repository files; requested fixes use narrow changes and targeted verification. Full system builds require a request covering that build, and neither diagnosis nor fixes authorize activation.

## Runtime problem diagnosis

Use [Kaenix Runtime Debug](../.agents/skills/kaenix-runtime-debug/SKILL.md), for example `$kaenix-runtime-debug diagnose why screen sharing fails in my Niri session`, for problems in the running desktop, services, or hardware integrations. The skill compares repository intent, the active generation, and writable state using targeted logs and session/device evidence. Diagnosis-only requests preserve files; requested fixes permit narrow repository changes. Live settings changes, service restarts, activation, logout, and reboot require explicit instructions covering those actions. Unavailable session/device access and runtime behavior still needing verification are reported separately from successful configuration checks.

## Repository configuration and the active system

A configuration that evaluates successfully is not automatically the active generation. Inspect `/run/current-system` separately when comparing the active generation with the repository. Evaluation/build results do not prove activation or runtime testing.

The user can build the entire system with `sudo nixos-rebuild build --flake path:.#syrup`. For routine changes, follow the README's activation workflow. For reinstallation or another machine, use the [migration guide](MIGRATION.md).

Login/lock, Kitty appearance, notifications, audio, screen sharing, tablet, GPU/offload, suspend, and external displays still require separate runtime tests. Passing build checks does not prove that all these functions work.
