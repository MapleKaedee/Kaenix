# Changelog

## 2026-10-21 — Version-aware documentation research skill

- Add project-local `kaenix-docs` with **Kaenix Docs** metadata and default automatic discovery. Keep the skill research-only, using existing tools without Context7, helper scripts, new dependencies, or global installation. Cover the checkout, proposed revisions, and installed/running targets separately; preserve the owning workflow's action boundaries.
- Resolve input names through the root lock mapping and `follows` graph before selecting sources. Inspect configured package sets, overrides, and vendored provenance/local adaptations; use matching official sources and report missing or newer-only evidence explicitly. Permit targeted lock-preserving evaluation with import-from-derivation disabled, without builds or activation.
- Add conditional research links to feature, review, update, build-debug, and runtime-debug skills, plus a context-index route and a short configuration-guide introduction. Keep the procedure in the new skill; existing skill frontmatter and metadata are unchanged.
- Complete manual lookup walkthroughs: the root Home Manager input maps to `home-manager_2` at `ec80131710bffcdf3b8498cf41f3a0579833b023`; inspect its Kitty option definition and evaluate the configured enable flag as `true`. Inspect nixpkgs `09063bd1f2b36fd9fd793c36dfade7bd40a93dfc` and evaluate the host's `khal` as version `0.14.1` with the local `sphinxBuilders = "html man"` override, rather than the upstream list. Trace mpv/PlayKit's recorded `4921c6796620a13c2c03266f368d59d354a67b72` snapshot, original-hash manifest, local `cache_dir=xdg` option, Lua adaptation, and Home Manager asset wiring by source inspection.
- Validation passes: all nine skills pass the bundled skill-creator validator; metadata YAML, generated metadata comparison, local links/anchors, and tracked/new-file whitespace checks pass. Source paths and the Kitty/khal values are resolved with offline, read-only Nix evaluation using `--no-update-lock-file` and `--option allow-import-from-derivation false`. Initial sandbox daemon access is blocked; the same source lookup succeeds through permitted daemon access, distinguishing the environment limit from a configuration fault.
- Review unavailable-source, blocked-evaluation, and newer-documentation handling by manual instruction inspection; no network-failure injection or mismatched-version tool trial is performed. Review B02, B04, B05, and B06 for static routing consistency, retaining review-only behavior, package ownership, lock/index preservation, and runtime evidence limits. Preserve the scenario catalog/protocol and all historical results; no independent model trial is run.
- Preservation checks retain existing staged work, the Git index, public README, Nix configuration, lockfile, and all out-of-scope baseline files. Prior changelog content remains unchanged. No package/check/system build, activation, live application probe, staging, commit, or push is performed. These structural checks and manual walkthroughs do not prove automatic skill discovery, active settings, successful package outputs, or runtime compatibility; no activation is required for this instruction-only change.

## 2026-10-21 — Focused agent context and shared guidance

- Consolidate startup policy in `AGENTS.md`: use task-relevant guide sections, implementation, and recent history; reuse already-read context until relevant files, scope, or evidence change. Keep hard boundaries explicit while replacing the directory inventory and validation command list with links to their existing owners. Retain module/package conventions, shared shell/terminal alignment, writable seed protection, README ownership, action authorization, and honest reporting.
- Turn `docs/kaenix.md` into a concise task router. Removed feature summaries remain in existing configuration, mpv, gaming, and migration guides; identify DankGreeter explicitly in the configuration directory map. Keep host/user/platform/time-zone/path orientation and links to the existing documentation checklist and behavioral scenarios.
- Replace repeated startup paragraphs across all eight skills with the shared policy and relevant task references. Remove generic language/ownership reminders and redundant feature-delivery authorization wording; retain task-specific review-only, diagnosis-versus-fix, restoration, live migration, validation, and reporting constraints. Shorten skill introductions in configuration, validation, and backup guides while retaining invocation examples, reader-relevant limits, and the owning skill links. No new skill or documentation layer is introduced.
- Review the placement of removed material: the directory map and feature facts live in `docs/CONFIGURATION.md`; check commands/coverage in `docs/VALIDATION.md`; installation guard/state versions in `docs/MIGRATION.md`; game/video details in their existing guides; documentation ownership/language/authorization in `AGENTS.md`; backup selections and full-copy semantics in `docs/BACKUP.md`; task procedures in their existing skills. Dated changelog entries remain historical and unchanged.

| Documents | Words before / after | UTF-8 bytes before / after |
| --- | --- | --- |
| `AGENTS.md` | 1,051 / 725 | 7,718 / 5,732 |
| Context index | 460 / 228 | 3,667 / 2,325 |
| Eight skills combined | 8,115 / 7,757 | 59,552 / 57,158 |
| Configuration, validation, and backup guides combined | 4,613 / 4,358 | 34,964 / 33,032 |

- Counts compare the working tree immediately before this cleanup with the result, including the earlier uncommitted scenario work. Shared startup text (`AGENTS.md` plus the index) falls from 1,511 to 953 words, about 37%; these are whitespace-delimited word and UTF-8 byte counts, not measured model tokens, cost, speed, or behavioral improvements. The newly appended history is excluded from size comparisons.
- Static validation passes: all eight skills pass skill-creator validation, frontmatter and metadata remain unchanged, local links/anchors resolve, whitespace and staged/unstaged `git diff --check` pass, and all eight unchanged scenarios remain consistent with their owning guidance. Source cross-checks retain B01 README/history boundaries, B02 inline-module scope and report-only review, B03 seed preservation/migration, B04 centralized package placement, B05 lock/index-preserving validation, and B06–B08 evidence/no-change/procedure constraints. This is a static consistency review, not a fresh model trial; previous trial results do not validate these revised instructions.
- Preservation checks pass for the existing checklist, scenario catalog/protocol, backup data selection/recovery sections, validation command/evidence sections, executable guide examples, and all prior changelog content. All 148 out-of-scope baseline hashes match, including the public README, Nix configuration, lockfile, skill metadata, and Git index. No new repository files, model runs, Nix evaluation/builds, activation, commit, or push are performed.

## 2026-10-21 — Agent behavioral scenarios and documentation checklist

- Add a scoped documentation/comment checklist to the existing Kaenix Review skill: verify facts and contracts, distinguish configured/build/active/runtime evidence, retain history and constraints, check reading order and references, and leave accurate text unchanged. Link its canonical location from the validation guide and context index; keep review-only work report-only and preserve skill metadata.
- Add [eight synthetic behavioral scenarios](tests/agents/scenarios.json) and an [isolated paper-exercise protocol](tests/agents/README.md). Cover public README ownership, review boundaries, seed preservation/migration, package placement, lock/index-preserving validation, unsupported runtime claims, valid no-change results, and shortening without losing history or procedural constraints. Update Kaenix Validate to select affected cases for changed decisions; wording-only edits need no model run. The method is informed by `ryan4yin/nix-config/agents` at `d2b11840d0c6cf2a1daed86f6fc183be079553fb`, with provenance in the guide and new Kaenix-specific fixtures.
- Run B02, B03, B06, and B07 as fresh independent `gpt-6.1-sol` sessions with high reasoning through Codex Desktop CLI `0.163.0`, without the parent conversation. Supply only the inactive-exercise protocol, case request/source map, root guidance, and applicable skill bodies; withhold rubric and expected answers. Inspect each returned artifact and actual tool-call trace: each graded actor makes exactly one permitted packet read and no other tool calls. The system/developer/tool context still comes from the runtime; input isolation is not a separate OS sandbox.
- Repair a fixture ambiguity before scoring B02: its original required outcome prohibited edit actions while also requiring remediation advice. Suite version 2 explicitly permits advice without treating a review as authorization to apply it; retain the initial response as ungraded and repeat with a fresh actor. Final comparison with implementation then finds that the synthetic seed declarations use the wrong option shape and Kitty's shell setting is outside `settings`. Suite version 3 corrects B02/B03/B05 and the B02 diff hunk. Repeat affected B02/B03 in fresh sessions; retain their earlier observations as historical, not results for the corrected source. B06/B07 packets are mechanically byte-identical across versions and their original results remain applicable. B05 remains static-only. No skill correction is needed.

| Case | Diagnostic outcome | Evidence |
| --- | --- | --- |
| B02 | Pass | Reports the new undefined Home Manager `lib`/`pkgs` references and the shell-selection conflict, suggests remediation, returns no edited artifact, and states no checks ran |
| B03 | Pass | Changes only the seed's Mod+T proposal, retains Mod+E, preserves the existing home, explains rebuild preservation, and gives a targeted user-run migration |
| B06 | Pass | Corrects activation/Wayland/GPU/audio overclaims, preserves the dated successful headless check, and reports the evidence limits |
| B07 | Pass | Reports no actionable finding and returns the original 406-byte document including its final newline; mechanical SHA-256 comparison matches |

- Each graded response satisfies its required outcomes with no forbidden outcome or observed protocol violation. B01/B04/B05/B08 are statically inspected only and have no model result. These are one-sample diagnostic paper exercises, not an A/B comparison, pass-rate estimate, real editing workflow, automatic discovery test, or proof of runtime enforcement. Raw packets/responses/traces and the manifest remain in temporary task artifacts outside the repository; a clone contains this summary and the reusable catalog/protocol.
- Freeze trial inputs at working-tree base `759a746e07f683c6703e98dfe6c5926d4ae9ee46` with the SHA-256 values below. The base commit alone does not contain these uncommitted changes. The original ungraded B02 catalog digest is retained separately; the actor packet excludes grading fields and did not change. Packet/response digests and session IDs are in the temporary manifest and observations.

```text
AGENTS.md                         83ce47b7852a86a86ddee99005bcb921211b167929e5f4b8d659fde30438baed
kaenix-review/SKILL.md             e055b504a17dbe46019a7a5bdc5726e8686514135b8ac889d82307f68f5fed97
kaenix-gui-baseline/SKILL.md        20a20115caf3fbd2c82607e5441de1e6f82c75e71ec392341dfd413812995336
tests/agents/README.md             55f9317c78aaf943adb5c4c9ac5e40512f7e832b63c7654840c9c4f5cd3d45a0
tests/agents/scenarios.json (v3)    b4e8f8f2a8dda0f0fec370eaeb254ae5f93878ecb89997a585fa39b01882a6b2
tests/agents/scenarios.json (v2)    129a8282a0624b0d09c417da9007629050ca11b63f5be406eaee51d63a57d8ac
tests/agents/scenarios.json (v1)    97d0fdb81ebd279b94b5530b092c9653895d4d72870226d0fb7e207ca51b04e2
B07 unchanged artifact            17ba249430ec9c3c9b54668b54bce00d0e1ebbabf8fd0596fc69dbd85cba5d9c
```

- Static validation passes: both changed skills pass skill-creator validation; frontmatter, YAML metadata consistency/preservation, all eight catalog entries and referenced skills, safe synthetic paths, artifact target, local links/anchors, all changed/new-file whitespace, temporary helper syntax, and staged/unstaged `git diff --check`. Preserve all 155 out-of-scope baseline hashes, including the public README, root instructions, Nix configuration, flake lockfile, existing skill metadata, and Git index. Use an existing Python 3.13 interpreter with the existing pure-Python PyYAML module for validation; Python 3.14 probes encountered a sandbox syscall restriction. No dependencies are installed, and no Nix evaluation/build, activation, live migration, commit, or push is performed.

## 2026-10-21 — Steam gaming with ProtonPlus and optional Gamescope

- Add the explicitly imported Steam feature with Protontricks, nested Gamescope, and GameMode using standard NixOS module defaults. Use Steam's module-provided 32-bit graphics/audio integration and controller rules; include MangoHud, Gamescope, and GameMode in its FHS environment. Install ProtonPlus, MangoHud, and GOverlay through the user package list, with compatibility-tool downloads and overlay preferences remaining writable.
- Move detailed Steam configuration and usage from `docs/CONFIGURATION.md` into `docs/steam.md`, leaving a short linked summary and updating the documentation index and validation links. Cover first launch, ProtonPlus-managed tools, GOverlay preferences, per-game NVIDIA/MangoHud/Gamescope/GameMode launch options, and runtime verification including governor restoration. Retain the existing PRIME offload, LAVD/power management, firewall defaults, and Niri session; enable no Gamescope login session, Gamescope privileged scheduling capability, or global overlay. Update feature counts from 26 to 27 and package references; preserve the public README and pinned inputs.
- Initial Steam validation passes: flake evaluation with `--no-build --no-update-lock-file path:.`; focused evaluated gaming/package/GPU/scheduler/firewall assertions; non-writing Nix formatting; 29 local documentation links/anchors; eight-file whitespace and 27-feature explicit-import inventory; staged/unstaged `git diff --check`. All six initial package builds pass: Steam 1.0.0.87's configured runtime and supporting dependencies build locally, while Protontricks 1.15.0, ProtonPlus 0.6.8, MangoHud 0.8.4, Gamescope 3.16.31, and GOverlay 1.9.4 are realized from cache. Gamescope help exits successfully, and the pinned executable confirms the SDL backend and cursor-grab option. The public README, flake inputs/lockfile, NVIDIA/power/SCX features, installation settings, and Git index retain their original checksums. No full system build, activation, reboot, Steam/game/GUI launch, hardware/performance test, commit, or push is performed.
- GameMode and documentation-move validation passes: fresh flake evaluation with `--no-build --no-update-lock-file path:.`; focused defaults/service/wrapper/runtime/GPU/scheduler/firewall assertions; non-writing Nix formatting; 33 local documentation links/anchors; seven-file whitespace and unchanged 27-feature explicit-import inventory; staged/unstaged `git diff --check`. GameMode 1.8.2 and its 32/64-bit libraries are realized from cache, the updated Steam runtime builds locally, and the generated empty `gamemode.ini` builds successfully. Static inspection confirms `gamemoderun`, Gamescope, and MangoHud in Steam's FHS environment, and ELF32/ELF64 preload libraries referenced by the launcher. Initial package/runtime results above remain separate from these checks. The same README, inputs/lockfile, NVIDIA/power/SCX, installation, and index preservation checks pass. No activation, service start, live GameMode request, game/GUI test, full system build, commit, or push is performed.

## 2026-10-21 — LAVD scheduling with automatic power profiles

- Add the imported SCX service feature using the pinned `pkgs.scx.rustscheds` package and `scx_lavd --autopower`. Start at boot and follow the existing power-profiles-daemon profile, keeping other LAVD defaults and the current CachyOS kernel. Use the standard NixOS service without enabling scx-loader or duplicating its package in explicit lists.
- Document activation, service/kernel status, power-profile verification, and temporary/permanent disable steps. Update the service-category references and feature count from 25 to 26. Preserve the public README, flake inputs/lockfile, hardware configuration, and state versions.
- Validation passes: flake evaluation with `--no-build --no-update-lock-file path:.`; evaluated service/package assertions and generated unit inspection; non-writing Nix formatting, 19 local documentation links/anchors, seven-file whitespace, feature inventory, and staged/unstaged `git diff --check`. The SCX 1.1.2 package is realized from the configured cache; `scx_lavd --autopower --version` exits successfully without attaching a scheduler. Help output confirms `--autopower` but exits 255 because the pinned `clap_main` wrapper exits with -1 when help is requested. The README, lockfile, kernel feature, and power feature retain their original checksums. No full system build, activation, reboot, commit, push, scheduler attachment, or runtime power-profile/performance test is performed.

## 2026-10-21 — Documentation eligible for version control

- Remove the `docs/`, `CHANGELOG.md`, and both `AGENTS.md` ignore rules and the obsolete personal-documentation comment. Preserve build-output, `.claude`, and Python-cache ignore rules.
- Align active agent instructions, documentation storage/backup guidance, and affected skill wording with version-controlled documentation. Becoming eligible for Git does not stage, commit, or publish these files; historical changelog entries retain the previous policy as dated context.
- Validation passes: all six guides, `CHANGELOG.md`, and root `AGENTS.md` are not ignored and appear as eligible untracked files; representative build-output, `.claude`, and Python-cache paths remain ignored. Both affected skills pass skill-creator validation; 76 local links/anchors, changed-file whitespace, and staged/unstaged `git diff --check` pass. Preserve historical changelog entries and all 150 out-of-scope file checksums, including the public README, Nix configuration, lockfile, skill metadata, and Git index. No staging, commit, push, Nix evaluation/build, or activation is performed.

## 2026-10-21 — Project-local backup skill

- Add `.agents/skills/kaenix-backup/` using skill-creator, with English instructions, **Kaenix Backup** metadata, and standard automatic discovery. Prepare backups, create explicitly requested copies, and verify selected Kaenix/user data; provide restoration guidance without executing restores. Add no helper scripts, dependencies, or global installation.
- Preserve existing selections/exclusions and writable state; verify actual mounts, filesystem capability, available space, path overlap, unique destinations, source consistency, and copied content/metadata. Keep private backups outside the repository, avoid Nix-store dereferencing and unsafe archive extraction, and report partial or unverified results. Add backup-guide usage and update the context index.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, two-file structure, automatic discovery default, no unfinished placeholders, 76 local links/anchors across six guides and eight skills, whitespace including new/ignored files, and staged/unstaged `git diff --check`. Statically review complete repository and selected GUI backups, missing sources/mounts, insufficient space, overlapping paths, exFAT/NTFS, symlinks, active databases, interrupted copies, and checksum mismatches, including planning/verification-only requests, separately authorized writer stops, private data, and restoration boundaries. Preserve all 152 out-of-scope file checksums, including existing skills, the public README, configuration, lockfile, and Git index; pre-existing backup-guide content remains identical except its update date, and documentation stays ignored. No actual backup/restore, Nix evaluation/build, live action, operational backup testing, or fresh-session discovery testing is performed.

## 2026-10-21 — Project-local change review skill

- Add `.agents/skills/kaenix-review/` using skill-creator, with English instructions, **Kaenix Review** metadata, and standard automatic discovery. Review actionable defects, regressions, ownership conflicts, and migration gaps without implementing fixes, adding helper scripts/dependencies, or installing globally.
- Establish the actual diff scope and intended behavior, trace affected consumers, distinguish introduced and pre-existing issues, and report evidence with verified file/line locations and severity. Use targeted validation when useful, preserve read-only boundaries, and route explicitly requested implementation to existing workflows. Add validation-guide usage and update the context index.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, two-file structure, automatic discovery default, no unfinished placeholders, 71 local links/anchors across six guides and seven skills, whitespace including new/ignored files, and staged/unstaged `git diff --check`. Statically review wrong module scope, missing imports, duplicate package declarations and justified scopes, competing writers, seed migration, and shell/terminal alignment; also review clean-diff, explicit-base, untracked-file, pre-existing-defect, no-finding, and blocked-check scenarios. Preserve all 150 out-of-scope file checksums, including existing skills, the public README, configuration, lockfile, and Git index; documentation stays ignored. No Nix evaluation/build, live action, real review execution, or fresh-session discovery testing is performed.

## 2026-10-21 — Project-local input update skill

- Add `.agents/skills/kaenix-update/` using skill-creator, with English instructions, **Kaenix Update** metadata, and standard automatic discovery. Cover review-only requests, selected inputs, and explicitly requested full flake input updates without helper scripts, dependencies, global installation, or vendored asset refreshes.
- Preserve release lines, exact-commit plugin pins, existing edits, and shared input relationships. Review upstream changes and the resulting lock graph; permit narrow compatibility fixes, reassess affected workarounds, and use existing build/runtime debugging and validation skills. Keep live actions separately authorized. Add configuration-guide usage and update the context index.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, two-file structure, automatic discovery default, no unfinished placeholders, 61 local links/anchors across six guides and six skills, whitespace including new/ignored files, and staged/unstaged `git diff --check`. Statically review selected DMS, exact-commit plugin, explicit full update, review-only, existing lockfile edit, transitive change, network failure, and upstream incompatibility scenarios. Preserve all 148 out-of-scope file checksums, including existing skills, the public README, configuration, lockfile, and Git index; documentation stays ignored. No dependency update, Nix evaluation/build, live session change, real update testing, or fresh-session discovery testing is performed.

## 2026-10-21 — Project-local runtime debugging skill

- Add `.agents/skills/kaenix-runtime-debug/` using skill-creator, with English instructions, **Kaenix Runtime Debug** metadata, and standard automatic discovery. Cover running desktop, service, and hardware-integration problems without helper scripts, dependencies, or global installation.
- Distinguish repository intent, active configuration, writable seeds, and observed runtime behavior. Use targeted service/log/session evidence, verify unit scope and current command interfaces, preserve diagnosis-only and requested-fix boundaries, and honor existing authorization for live actions. Route related work to the four existing skills; add usage guidance to the validation guide and update the context index.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, two-file structure, automatic discovery default, no unfinished placeholders, 51 local links/anchors across six guides and five skills, whitespace including new/ignored files, and staged/unstaged `git diff --check`. Statically review failed DMS service, stale terminal binding, audio, portal/screen-sharing, tablet, unavailable GPU/session access, and requested repository-fix scenarios, including routing and separately authorized live actions. Preserve all 146 out-of-scope file checksums, including existing skills, the public README, configuration, lockfile, and Git index; documentation stays ignored. No Nix evaluation/build, real failure reproduction, live session changes, runtime testing, or fresh-session discovery testing is performed.

## 2026-10-20 — Project-local build debugging skill

- Add `.agents/skills/kaenix-build-debug/` using skill-creator, with English instructions, **Kaenix Build Debug** metadata, and standard automatic discovery. Diagnose source visibility, evaluation, fetch/substitution, dependency build, configuration-check, and environment/tooling failures without helper scripts, templates, or global installation.
- Keep diagnosis-only requests free of repository edits; apply narrow fixes when requested. Trace actionable evidence, reproduce targeted builds through pinned host packages, verify required outputs and the derivation selected by Kaenix, and use `kaenix-validate` for regression checks. Preserve requested functionality and action boundaries; add a link and invocation example to the validation guide.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, local references/anchors, placeholders, whitespace including new/ignored files, project-local placement, and staged/unstaged `git diff --check`. Statically review unknown options, untracked sources, dependency failures, missing outputs, daemon/network restrictions, and cached results, including diagnosis-only and requested-fix boundaries. Preserve all 145 out-of-scope file checksums, including existing skills, AGENTS.md, the root README, configuration, lockfile, and Git index. Keep six guides and ignored documentation status. No real build failure is reproduced, and no Nix evaluation/build, configuration fix, activation, or runtime testing is performed.

## 2026-10-20 — Project-local feature implementation skill

- Add `.agents/skills/kaenix-feature/` using skill-creator, with English instructions, **Kaenix Feature** metadata, and standard automatic discovery. Cover package-list edits, existing feature changes, and new configured features without helper scripts, templates, or global installation.
- Follow existing imports, NixOS/Home Manager scope, package ownership, pinned inputs, shared globals, and writable state handling. Route GUI imports to `kaenix-gui-baseline` and check selection to `kaenix-validate`; add a link and invocation example to the configuration guide.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, local references/anchors, whitespace including new/ignored files, project-local placement, and staged/unstaged `git diff --check`. Statically review package-only installation, existing feature modification, mixed NixOS/Home Manager features, module-installed packages, writable settings, and unavailable pinned packages/options. Preserve all 143 out-of-scope file checksums, including existing skills, AGENTS.md, the root README, lockfile, configuration, and Git index. Keep six guides and ignored documentation status. No application feature, Nix configuration, activation, or runtime behavior is changed; no Nix evaluation/build is performed.

## 2026-10-20 — Project-local GUI baseline skill

- Add `.agents/skills/kaenix-gui-baseline/` using skill-creator, with English instructions, **Kaenix GUI Baseline** metadata, and standard automatic discovery. Cover selected DMS preferences, Niri fragments, terminal themes, and OpenTabletDriver profiles without additional scripts or global installation.
- Preserve unrelated settings, parameterized paths, writable seeds, and minimal session state. Separate repository baseline changes from live migration and delegate check selection to `kaenix-validate`. Add a configuration-guide link and invocation example; require Kaenix skills to reside in the repository unless global installation is explicitly requested.
- Validation passes: skill-creator `quick_validate.py`, metadata YAML, local references/anchors, whitespace including new/ignored files, and staged/unstaged `git diff --check`. Statically review selective DMS imports, plugin paths, Niri bindings, generated themes, tablet profiles, and unavailable exports. Preserve all 140 out-of-scope file checksums, including the existing validation skill, root README, configuration, lockfile, and Git index. Keep six guides and ignored documentation status. No GUI settings are imported, and no Nix evaluation/build, live migration, activation, or runtime testing is performed.

## 2026-10-20 — English as the project and communication default

- Set English as the default for project content and communication in AGENTS.md, unless the user explicitly requests another language. Preserve document formats and technical identifiers.
- Align the `kaenix-validate` reporting rule and project context with that default.
- Validation passes: skill-creator `quick_validate.py`, language-rule consistency, local documentation links/anchors, whitespace including ignored files, and staged/unstaged `git diff --check`. Preserve the root README, configuration, Git index, and ignored documentation status. No Nix evaluation/build or activation is performed.

## 2026-10-20 — English documentation and validation skill

- Translate all six active guides, the historical changelog, and the `kaenix-validate` instructions and metadata into English. Preserve filenames, the compact documentation structure, technical meaning, skill identity, invocation policy, and report language behavior.
- Translate explanatory comments and messages in examples while preserving command logic, paths, identifiers, versions, hashes, shortcuts, and historical results. Update links to translated heading anchors; keep the two existing English changelog sections unchanged.
- Validation passes: skill-creator `quick_validate.py`, YAML metadata, local links/anchors, whitespace, example shell syntax, and comparisons of commands, inline technical literals, numeric values, dates, and historical entry order. All 134 out-of-scope file checksums remain identical, including the root README, AGENTS.md, configuration, and Git index; documentation stays ignored. No Nix evaluation/build, activation, or runtime testing is performed.

## 2026-10-20 — Local documentation cleanup

- Reduce `docs/` from 15 documents to six active guides. Remove the chat continuation summary, three change reports, four pre-installation archives, and the old transcript along with empty directories, without creating a replacement archive.
- Shorten the index, validation history, skill explanation, and general application descriptions. Preserve backup decisions, conversation backup notes, writable state ownership, binding migration, and Kaenix-specific workarounds. Clean up links to removed documents; convert three historical changelog links to plain text without changing earlier validation results.
- Documentation validation following `kaenix-validate` passes: exactly six documents, 29 valid local links/anchors, whitespace including ignored files, ignored status, and staged/unstaged `git diff --check`. Text size decreases from 233,750 to 38,866 bytes and from 5,274 to 463 lines. Checksums of 136 out-of-scope files remain identical, including the root README, configuration, skill, and Git index. No Nix evaluation/build, activation, or runtime testing is performed.

## 2026-10-20 — Local Kaenix validation skill

- Add `.agents/skills/kaenix-validate/` using the skill-creator initializer, containing `SKILL.md` and `agents/openai.yaml`, with the **Kaenix Validate** display name and standard automatic discovery. Store the skill in the repository without installing it in global Codex configuration or adding test scripts.
- Select validation from the user's scope or staged/unstaged/untracked changes, mapping checks to their actual implementation, evaluating all four shell/terminal combinations where relevant, and running all checks for comprehensive requests. Use `path:.`, `--no-link`, and `--no-update-lock-file`; distinguish evaluation/build/runtime results, cache use, configuration failures, and environmental constraints. The skill does not fix configuration or activate the system; full system builds require an explicit request.
- Add links and invocation guidance to the local index and validation guide. Documentation and the changelog remain ignored; preserve the root README, Nix configuration, lockfile, hardware, and Git index.
- Validation passes: `quick_validate.py`, the two-file structure, YAML metadata parsing, standard automatic discovery policy, local references/anchors, whitespace including new/ignored files, and `git diff --check` for staged/unstaged changes. Documentation, terminal/shell, DMS seed, mpv, and Nix daemon failure scenarios are reviewed statically against the skill instructions and check coverage. No Nix evaluation/build, Kaenix test suite, activation, GUI testing, or skill discovery test in a new Codex session is performed.

## 2026-10-20 — Alacritty and default terminal selection

- Add `globals.defaultTerminal = "alacritty"`, with helper-validated `"alacritty"` or `"kitty"` choices. Both terminals remain installed through Home Manager; Alacritty follows `globals.defaultShell` in login mode, while Kitty configuration is preserved.
- Align `$TERMINAL` and the `xdg-terminal-exec` default list through the Niri module. Change the `Mod+T` baseline to the generic launcher without modifying the writable active binding file. Nix now manages default terminal selection; document Home Manager backups and the one-time manual binding migration after activation.
- Add Alacritty font, padding, transparency, cursor, scrollback, window shortcuts, and font-size shortcuts. Initial colors follow Kitty's palette and are imported from one writable seed that DMS can update; there are now 17 seeds and 25 features.
- Add a headless terminal check, expand the fixture to four terminal/shell combinations, and test preservation of edited Alacritty themes when seeding again. Update package references, agent instructions, and local documentation; preserve the public README, lockfile, hardware configuration, and state versions.
- Validation passes: flake evaluation, all four Alacritty/Kitty and Nushell/Fish combinations, rejection of invalid terminal choices, builds of `terminals`, `shells`, `niri-config`, `seed-files`, and `seed-integration`, formatting of relevant Nix files, and `git diff --check`. The terminal check inspects generated Home Manager TOML and the Alacritty 0.17.0 migrator dry run, desktop entry selection, and argument forwarding through `xdg-terminal-exec` 0.14.3. Verification of 17 seeds preserves theme edits and DMS settings. This terminal change does not include a full system build, activation, active binding migration, reboot, commit, push, or GUI/DMS color testing in a real session; follow the activation and one-time migration steps in the configuration guide.

## 2026-10-20 — Fixing khal manual output

- Add a NixOS overlay specifically for `khal` in the DMS module, using `sphinxBuilders = "html man"` so the pinned Sphinx hook reads both builders when structured attributes are enabled. Fix the missing `man` output without disabling DMS calendar integration or replacing the package version/source.
- Record the cause and workaround review guidance in the configuration guide and update Kaenix context. Preserve the lockfile, flake inputs, state versions, and public README.
- Validation passes: flake evaluation without check builds, DMS module formatting, whitespace checks, and a full system build through `nixos-rebuild build --flake path:.#syrup` as the user through the Nix daemon. Evaluation confirms enabled DMS calendar integration, unchanged `khal` version 0.14.1, and the same derivation as the temporary corrected build that produces `khal.1.gz` and passes 333 tests. System output: `/nix/store/22imd8f5ak5awa2j274bpf1j29yrv4fk-nixos-system-syrup-26.11.20261017.09063bd`. The `sudo -n` attempt requires a password, so the build runs without sudo. The agent does not activate, reboot, commit, push, or test calendar/GUI runtime.

## 2026-10-19 — mpv_PlayKit main with an English UI

- Add the `modules/apps/mpv.nix` feature using native mpv from pinned nixpkgs, PlayKit **main** assets at commit `4921c6796620a13c2c03266f368d59d354a67b72`, and default associations for ten video MIME types. Do not use lite, install duplicate mpv packages, add inputs, or update the lockfile.
- Include uosc, uosc_addones, FFmpeg thumbnails, volume/mute state, UI fonts, and three optional shaders. Use English for the UI and configuration comments; preserve identifiers, vendor comments, and licenses. Record sources, original hashes, and patches in `config/mpv/UPSTREAM.md` and the provenance manifest.
- Adapt the backend to Wayland/PipeWire and mpv 0.41.0 options; remove sample filters/placeholder paths and Windows/AI/VapourSynth integration, the updater, and the external subtitle downloader. Separate read-only configuration from XDG state/cache; use per-instance PIDs for thumbnails. No shader is active at startup and no seeds are added; preserve the existing 16 seeds.
- Add the `mpv-config` check for configuration actually mapped by Home Manager, all English keys, video MIME types, script startup, three shader profiles, writable presets/volume/resume state, and FFmpeg thumbnails from two instances in temporary homes. Update AGENTS.md, the active index/guides, and the [mpv guide](docs/MPV.md). Preserve the public README.
- Validation passes: mpv 0.41.0 is realized, flake evaluation without builds, all five check builds, Nushell/Fish fixtures, formatting of four changed Nix files, and `git diff --check`. The mpv check confirms 122 English keys, video MIME defaults without replacing browser/audio/image defaults, all shader profiles and queue clearing, writable presets/volume/resume state, intact read-only configuration, and FFmpeg thumbnails from two instances. Evaluation confirms one mpv package and 16 seeds; all 77 out-of-scope file hashes and original fonts/shaders remain identical. No full system build, activation, reboot, staging, commit, push, or GUI/GPU/audio/clipboard testing in a real session is performed.

## 2026-10-18 — Package list at the modules root

- Move `packages.nix` from the repository root to `modules/packages.nix` without changing its contents; update the import in `modules/default.nix` to `./packages.nix`.
- Update AGENTS.md and active guides with the new path. Add a note about the current location to the earlier refactoring report without rewriting historical results. Preserve the root README and the user's flake/lockfile changes.
- Validation passes: identical system and Home Manager activation derivations before/after the move, flake evaluation without builds, formatting checks for both Nix files, active documentation path references, and `git diff --check`. Package list contents and hashes of 77 out-of-scope files remain identical. Preserve ignored documentation status; no check rebuilds, activation, or runtime testing are performed.

## 2026-10-18 — One file per feature and centralized packages

- Merge NixOS and Home Manager configuration into one `.nix` file per feature, retaining separate user-module argument contexts. Preserve the six categories and explicit imports; remove eight package-only features, leaving 23 features.
- Centralize explicit system, Home Manager, and font package lists in root `packages.nix`. Keep program/service activation and feature-specific package choices with their features, and add comments pointing to packages installed through modules.
- Merge `kaenix.seedFiles` options and activation into `modules/system/home-manager.nix`; preserve all 16 seeds, activation order, writable behavior, and the unchanged helper. Adjust asset paths and order the Nushell greeting before Starship integration to preserve generated configuration.
- Update AGENTS.md and active guides; add the comparison report. Preserve the root README; record suggested structure and example-path changes in the report.
- Validation passes: identical system/user/font package multisets, identical user environment/services, and all 16 seeds byte-identical. Of 1,795 generated files, 1,793 are identical; the other two differ only in store-path hashes in manual/font caches. Home metadata is preserved; system settings and units match after store-hash normalization.
- Flake evaluation, Nushell/Fish fixtures and invalid-shell rejection, all four check builds, and formatting checks for 31 Nix files pass. Active imports/paths, documentation links, ignored status, 48 out-of-scope file hashes including the user's flake/lockfile and Git index, and `git diff --check` pass. No full system build, activation, reboot, staging, commit, push, or runtime testing is performed.

## 2026-10-18 — Kaenix context and README ownership

- Rename `docs/README.md` to `docs/kaenix.md`, preserving its previous content and explaining its role as the primary project context and local documentation index.
- Update active guide links and English AGENTS.md rules: only the user edits the root README; agents may read it and suggest changes, while all of docs may be updated to reflect repository changes.
- Validation passes: preserved original document contents after renaming, 59 valid local links/anchors, and unchanged root README, Git index, 104 out-of-scope file hashes, and changelog history. Ignored local documentation status and `git diff --check` are verified; no staging, commit, build, or rebuild is performed.

## 2026-10-18 — Synchronizing active documentation

- Add a documentation index and dated archives for earlier migration, backup, continuation context, and validation guides. Preserve historical contents with archive markers and adjusted relative links; leave existing transcripts and dated reports unchanged.
- Align the README and active guides with the current `syrup` configuration: installed NixOS, enabled hardwareReady, configured systemd-boot, both state versions at 26.05, six module categories, Nushell/Fish defaults, four checks, and 16 seeds.
- Update backup paths to `/home/kaede/Kaenix`, preserve earlier data choices, and explain that a complete copy includes ignored documentation, untracked files, and Git metadata. Do not claim a successful backup.
- Separate routine use from reinstallation/adaptation and distinguish evaluation/build evidence from activation/runtime. Nix provides Python for checks/seeding; no global interpreter is needed.
- Change only explanatory comments in `installation.nix`; evaluation confirms unchanged values and both state versions at 26.05.
- Validation passes: 59 local links/anchors and code references across seven active guides and four archives, preserved archive contents, 97 out-of-scope files, and the Git index. `nix flake check --no-build path:.` and `git diff --check` pass. No rebuild of the four checks, activation, reboot, backup, staging, commit, or GUI testing is performed; earlier check build results remain linked to the dated reports.

## 2026-10-18 — Modules organized by category

- Replace the system/user module split with `desktop`, `shell`, `apps`, `hardware`, `services`, and `system` categories containing 31 feature folders with explicit imports.
- Place each feature's NixOS `default.nix` and Home Manager `home.nix` modules side by side. Split mixed package/peripheral modules by responsibility while preserving system/user package scope.
- Preserve host/user entry points, flake wiring, configuration assets, scripts, helpers, wallpapers, and the 16 writable seed files. Do not add dependencies, feature toggles, or auto-discovery.
- Update the README, AGENTS.md, and local configuration documentation; preserve historical notes. Record mapping and validation details in the migration notes.
- Validation against the working-tree baseline passes: identical system/user packages, user environment/services, all 16 seeds, and user profile symlink targets. Of 1,795 compared files, 1,793 are byte-identical; two differ only in Nix store path hashes in manual/font-profile caches.
- Default Nushell/Fish fixtures and invalid-shell rejection pass. Flake evaluation, all four check builds, formatting checks for 60 Nix files, and `git diff --check` pass. Derivation differences caused by list ordering and store paths are explained in the migration notes; no system activation or runtime testing is performed.

## 2026-10-18 — WhatsApp through Brave

- Remove `pkgs.zapzap` from Home Manager packages at the user's request; retain Discord.
- Update the README and local documentation to use WhatsApp Web through Brave, without an additional WhatsApp client or launcher.
- Validation passes: Home Manager evaluation confirms ZapZap is absent, Discord remains declaratively installed, Brave remains enabled, and the activation derivation is valid. Module formatting and `git diff --check` pass; the lockfile is unchanged.
- Do not delete existing application data or accounts. System activation and WhatsApp login testing through Brave have not been performed.

## 2026-10-18 — ZapZap and Discord

- Add `pkgs.zapzap` and `pkgs.discord` to user `kaede`'s Home Manager packages using pinned nixpkgs without updating inputs or the lockfile.
- Use package-provided launchers, icons, and executables. Accounts and preferences remain writable; do not add autostart, Discord mods, GPU configuration, or global environment variables.
- Update the README and local documentation with instructions for opening the applications and linking WhatsApp through the phone's linked-devices menu.
- Validation passes: ZapZap 7.4.5 and Discord 1.0.161 appear in Home Manager packages, and the activation derivation is valid. Both packages are realized successfully; executables, visible desktop launchers, launcher command targets, and icons are available.
- `nixfmt --check modules/home/apps-home.nix`, `nix flake check --no-build path:.`, and `git diff --check` pass. The lockfile is unchanged. System activation and DMS launcher, login, notification, and GUI audio tests have not been performed.

## 2026-10-18 — nixfmt and nix fmt integration

- Add `pkgs.nixfmt` to Home Manager packages and the `formatter.x86_64-linux` output based on `nixfmt-tree` from the same host package set, without a new flake input or lockfile change.
- Provide explicit single-file and project formatting through `nixfmt` and `nix fmt`. Do not add Git hooks or editor format-on-save settings.
- Format only `flake.nix` and `modules/home/apps-home.nix`, and update the README and local configuration documentation. Preserve existing user changes.
- Validation passes: nixfmt 1.5.0 appears in Home Manager packages, the activation derivation is valid, and the formatter output uses `nixfmt-tree` from the same pinned package set. The nixfmt package is fetched from cache and the formatter wrapper builds successfully.
- `nixfmt --version` works from Nushell and Fish with a test PATH pointing to the built package. A temporary-directory test verifies file selection, recursive Nix formatting, preservation of non-Nix files, and identical results on repeated invocation.
- `nix fmt -- flake.nix modules/home/apps-home.nix`, `nixfmt --check` on both files, `nix flake check --no-build path:.`, and `git diff --check` pass. No system activation is performed; CLI availability in the active user profile awaits a rebuild.

## 2026-10-18 — nix-output-monitor

- Add `pkgs.nix-output-monitor` to Home Manager packages using pinned nixpkgs without an additional flake input.
- Provide `nom`, `nom-build`, and `nom-shell` for Nushell/Fish, with explicit invocation rather than replacement aliases for Nix commands.
- Update the README and local documentation with a `shells` check build example, progress/download/dependency-tree information, and an explanation that monitoring `nixos-rebuild` requires separate log piping.
- Validation passes: version 2.2.0 appears in home packages, the Home Manager activation derivation is valid, the package is fetched from Nix cache, and `nom --version` works from Nushell and Fish. `nom-build`/`nom-shell` are available as symlinks to `nom`.
- The `nom build --no-link --offline path:.#checks.x86_64-linux.seed-files` smoke test succeeds (exit 0, check already available in cache); `git diff --check` passes. The active system is unchanged.

## 2026-10-17 — Pavucontrol and EasyEffects

- Add `pkgs.pavucontrol` and `pkgs.easyeffects` to Home Manager packages for GUI mixer and audio effects settings.
- Preserve enabled PipeWire and PulseAudio compatibility. Do not enable EasyEffects services/autostart or select audio presets/devices automatically.
- Update the README and local audio configuration guide. Open the applications from the DMS launcher or with `pavucontrol`/`easyeffects`.
- Validation passes: Home Manager evaluation confirms Pavucontrol 6.2 and EasyEffects 8.3.0 in home packages, a valid activation derivation, enabled PipeWire/Pulse compatibility, and disabled EasyEffects services. `git diff --check` passes; system activation and GUI testing have not been performed.

## 2026-10-17 — Terminal and shell in Fastfetch

- Add the `terminal` (label `term`) and `shell` modules immediately before `disk` in `config/fastfetch/settings.json`, following the existing colors and label width.
- Validate JSON configuration and loading through Fastfetch. Changes apply after a Home Manager/NixOS rebuild.

## 2026-10-17 — Nushell and Fish with a Nix-selected default

- Add `globals.defaultShell = "nushell"` to select the login shell and Kitty shell through one setting. A shared helper rejects values other than `"nushell"` and `"fish"` with a clear message.
- Enable Nushell and Fish in NixOS/Home Manager and list both in `/etc/shells`. Nushell is the initial default; Fish remains available.
- Move Starship and eza into a shared module, move the theme unchanged from `config/fish/starship.toml` to `config/starship.toml`, and enable prompt integration for both shells.
- Add Nushell configuration: disabled banner, interactive-only Fastfetch, OSC 7/133 terminal integration, and an eza-based `ll` alias. Preserve Nushell's structured `ls` and Fish configuration/autopair.
- Add a login environment bridge through Bash that reads NixOS profiles and the Home Manager session variables package. NUL separation preserves `=` signs/newlines; convert PATH to a list and preserve the working directory.
- Add environment/shell startup tests and expand evaluation fixtures for both default choices. Pass evaluated NixOS globals to Home Manager to keep overrides consistent.
- Update the README and local configuration documentation with temporary shell switching, default changes through rebuilds, separate histories, and `path:` references for new unstaged files.
- Validation passes: system/Home Manager evaluation with both defaults, invalid-value rejection, `nix flake check --no-build`, and shell, seed-files, seed-integration, and Niri check builds. A Nushell login test in a clean home/environment finds `git`, `nix`, and `brave`, loads `BROWSER`, and preserves the working directory.
- Fish startup and greetings are verified; interactive Nushell loads Starship and one Fastfetch, while noninteractive commands remain free of greetings. No system activation or active-session shell change is performed; greeter login and Kitty prompt appearance after rebuilding still need checking.

## 2026-10-17 — GitHub CLI with Home Manager Git configuration

- Declare GitHub/Gist credential helpers through `programs.git.settings` in `modules/home/apps-home.nix` so Git uses the GitHub CLI account without requiring `gh` to write its read-only configuration.
- Keep GitHub CLI account configuration writable; do not put tokens in the Nix store.
- Add `wl-clipboard` for copying login codes in Wayland sessions.
- Document the error cause, authentication checks, and future login workflow in `docs/CONFIGURATION.md`.
- Validation passes: Home Manager evaluation, Git configuration build, GitHub/Gist helper and username parsing with Git, and `git diff --check`. `wl-clipboard` appears in home packages; `gh` remains unmanaged by Home Manager.
- GitHub CLI status confirms the active `MapleKaedee` account. Active system configuration is unchanged; clipboard checks after rebuilding remain necessary.

## 2026-10-16 — Private local documentation and offline backups

- Add root-level `docs/` and `CHANGELOG.md` to `.gitignore` and remove their existing entries from the Git index while preserving local files.
- Make the English README self-contained: remove links to private documents and include the required migration, writable-default, validation, and backup instructions directly.
- Document the GitHub plus external-drive backup strategy, including ignored documentation and hidden Git metadata in the complete offline working-directory copy.
- Keep earlier rewrite records as historical snapshots. Removing files from tracking does not erase copies in previous commits.
- Verify ignore rules, index removal, preserved local documentation, README links, and diff whitespace.

## 2026-10-16 — English README for the GitHub repository

- Rewrite `README.md` in English for `MapleKaedee/Kaenix`, with the repository URL and clone instructions.
- Add host and desktop component tables, configuration ownership, repository layout, deployment steps, and validation commands matching the implemented configuration.
- Remove the outdated note that Git metadata is unavailable; retain guidance to stage new flake source files.
- Credit `ryan4yin/nix-config` as inspiration for the README structure and retain links to the detailed project documentation.
- Verify local documentation links, Markdown structure, and the documentation diff. No system build is needed for this documentation-only update.

## 2026-10-16 — Backup and chat continuation

- Add `docs/BACKUP.md` following the user's choices: personal data, osu!, DMS settings/state, DMS assets in Niri/Kitty, the repository, and project conversations. Record components excluded from backup.
- Export available conversation messages to `docs/chat/2026-10-16-cachyos-nixos.md`, excluding tool output, reasoning, and internal instructions. The snapshot does not include the export turn's final response.
- Add `docs/CONTINUE-IN-NIXOS.md` for ChatGPT/Codex to read in a new chat; include decisions, implementation results, validation limits, and steps after a clean install.
- Update README links and the migration guide. Keep the rewrite diff history as a historical snapshot without rewriting it.
- Find local Codex history in `.codex` and its application profile in `.config/Codex`; document raw backups after closing the application without promising native cross-version import.
- No copy to the external hard drive has been made because the drive has not been detected as mounted. No active application data is changed.

## 2026-10-16 — CachyOS → NixOS rewrite

Status: implemented in the repository; not yet applied to the operating system. Detailed validation evidence is in [VALIDATION.md](docs/VALIDATION.md). Each changed configuration file is recorded in the inventory and diff.

| Area | Before | After and rationale |
| --- | --- | --- |
| Hardware/boot | Old UUIDs and forced GRUB | Keep old hardware as a placeholder; `installation.nix` holds bootloader/state versions and blocks deployment until replacement. |
| Flake inputs | Niri flake + Noctalia | nixpkgs Niri + DMS stable; plugins at previously used commits; lockfile updated by Nix. |
| Dotfiles | Symlinks to `/home/kaede/nnn` | Home Manager builds configuration and assets from the repository; checkout location is unrestricted. |
| Shell | Zsh + Oh My Zsh | Fish + Starship + eza + autopair; Fastfetch only in the Fish greeting. |
| Kitty | Old basic configuration | CachyOS appearance/shortcuts; writable DMS themes; remove the invalid `fastfetch` line. |
| Fastfetch | Old configuration | Maple-Tree appearance and `hakufetch.txt`; settings through Home Manager. |
| Niri | External flake, old dotfiles | Built-in nixpkgs module, CachyOS base KDL, explicit AMD rendering, optional DMS includes. Re-enable error notifications. |
| Desktop shell | Noctalia + wallpaper script on every rebuild | One DMS user service; copy Catppuccin and initial settings only when absent. |
| Login/lock | Noctalia Greeter | DankGreeter + Niri session; system PAM; no auto-login. |
| Plugins | Not declared | Pinned catWidget + mpvpaper; GUI can save plugin configuration. |
| Wallpaper | Directory in an external repository | Include local video and install it to `~/Pictures/Wallpapers`; remove Downloads paths. |
| GPU | Closed NVIDIA + PRIME sync + derivation override | Open NVIDIA + offload + power management; remove the `allowedReferences` workaround. |
| Browser | Installed Brave, global Firefox variables | Brave through Home Manager + MIME defaults; remove Firefox variables and globally forced NVIDIA VA-API. |
| ASUS | asusd/asusctl | Keep asusd enabled; locked asusctl 6.5.0 also provides ROG Control Center. This nixpkgs has no separate `rog-control-center` package. |
| Tablet | None | OpenTabletDriver module, daemon/udev; copy CTL-472 profile once; remove manual Niri autostart. |
| Gaming | No osu!lazer | `osu-lazer-bin` for the official distribution with online features. |
| HM backup | `.backup` can be overwritten | Do not overwrite `.pre-kaenix`; backup conflicts require explicit handling. |
| Validation | No checks | Seed tests, Niri validation before/after DMS fragments, and a system evaluation fixture. |

### Implementation decisions

- Express initial DMS configuration as Nix attributes; do not use official settings/session options for active state because they produce read-only symlinks.
- Create seed files atomically with mode `0600`, after Home Manager linking and before service reload. Do not replace existing files; reject legacy directory symlinks.
- Keep base KDL as a Nix-read file; the `niri-flake` input is unnecessary. Writable DMS fragments follow the CachyOS baseline.
- The pinned derivation shows that `asusctl` includes ROG Control Center. Enabling asusd installs both; a separate package entry would cause evaluation to fail.
- Do not add Direnv/Zoxide because they were not installed in the CachyOS source; omit the old conditional hooks. Shell, launcher, and clipboard histories, accounts, and osu! data are not copied.
- Preserve general packages unrelated to the rewrite. Remove `grub2`/`os-prober` from explicit packages; bootloader installation follows the clean-install module.
- Keep old wallpaper photos in `collection/` to preserve unrelated user assets.

### Tracking future changes

Add dated entries listing changes, rationale, relevant files, test results, and runtime limits. Export GUI settings back into the baseline when they should be reproducible; normal rebuilds intentionally do not overwrite active state.
