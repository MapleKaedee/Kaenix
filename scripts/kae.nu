# The package builder supplies KAE_CONFIG and a pinned Nushell interpreter.

def --env enter-repository [] {
    let repository = ($env.KAE_REPO? | default $KAE_CONFIG.repository | path expand)
    if not ($repository | path join flake.nix | path exists) {
        error make {msg: $"No flake.nix found in ($repository); set KAE_REPO to your Kaenix checkout"}
    }
    cd $repository
    $repository
}

def announce [program: string, arguments: list<string>] {
    print --stderr $"kae: ($program) ($arguments | each { to nuon } | str join ' ')"
}

def execute [program: string, arguments: list<string>] {
    announce $program $arguments
    exec $program ...$arguments
}

# Manage the Kaenix checkout from any directory.
#
# Command forms:
#   kae help [command]                  General or command-specific help.
#   kae check                           Evaluate without building checks.
#   kae test [checks...]                 Build all or selected validation checks.
#   kae build                           Build the system and create result.
#   kae switch                          Build and activate with sudo elevation.
#   kae update [inputs...]               Update all or selected flake inputs.
#   kae gc [--older-than DAYS]           Collect garbage; optionally prune generations.
#   kae optimize                        Deduplicate the Nix store.
#   kae fmt [--check] [paths...]          Format Nix files or check formatting.
#
# The default checkout is /home/kaede/Kaenix. Set KAE_REPO to select another
# checkout; relative formatting paths resolve from that checkout.
# Only update intentionally changes flake.lock. Commands run only the requested
# operation; use help to inspect effects before running it.
#
# Examples:
#   kae help update
#   kae gc --help
#   with-env {KAE_REPO: "/path/to/checkout"} { kae check }
def main [] {
    print (help main | str replace --all 'main ' 'kae ')
}

# Show general help or help for one command.
#
# Without a command, show the command forms and checkout defaults.
# With a command, explain its arguments, flags, defaults, effects, and examples.
# Help never invokes operations and works without an existing checkout.
#
# Examples:
#   kae help
#   kae help gc
#   kae gc --help
#   kae --help
def "main help" [command?: string # Command to explain; omit for general help.
] {
    let commands = [check test build switch update gc optimize fmt help]
    if $command == null {
        print (help main | str replace --all 'main ' 'kae ')
    } else if $command in $commands {
        print (help $"main ($command)" | str replace --all 'main ' 'kae ')
    } else {
        error make {msg: $"Unknown kae command: ($command)"}
    }
}

# Evaluate the flake without building its checks or activating a configuration.
#
# Runs nix flake check --no-build in the selected checkout. It may fetch inputs
# and populate Nix caches, but preserves flake.lock and does not request sudo.
# This checks evaluation; it does not prove that the checks or system build.
#
# Examples:
#   kae check
def "main check" [] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.nix [flake check --no-build --no-update-lock-file $"path:($repository)"]
}

# Build named validation checks, or all available checks when none are named.
#
# Discover checks from the selected checkout before validating names. Omit names
# to build every check; supply one or more names to limit the build.
# Preserves flake.lock, requests no sudo, and does not activate the system.
#
# Examples:
#   kae test
#   kae test shells
#   kae test shells terminals
def "main test" [...checks: string # Check names; omit to build all available checks.
] {
    let repository = (enter-repository)
    let target = $"path:($repository)#checks.($KAE_CONFIG.system)"
    let arguments = [eval --json --no-update-lock-file $target --apply builtins.attrNames]
    announce $KAE_CONFIG.commands.nix $arguments
    # Capture only discovery output. Builds and other operations stream directly.
    let discovery = (run-external $KAE_CONFIG.commands.nix ...$arguments | complete)
    if $discovery.exit_code != 0 {
        print --stderr --no-newline $discovery.stderr
        exit $discovery.exit_code
    }
    if $discovery.stderr != "" { print --stderr --no-newline $discovery.stderr }
    let available = ($discovery.stdout | from json)
    let selected = if ($checks | is-empty) { $available } else { $checks | uniq }
    let unknown = ($selected | where {|name| $name not-in $available })
    if not ($unknown | is-empty) {
        error make {msg: $"Unknown validation checks: ($unknown | str join ', '); available: ($available | str join ', ')"}
    }
    if ($selected | is-empty) { error make {msg: "No validation checks are available"} }
    let installables = ($selected | each {|name| $"($target).($name)" })
    execute $KAE_CONFIG.commands.nix ([build --no-link --no-update-lock-file] | append $installables)
}

# Build syrup without activation; leave the result symlink in the checkout.
#
# Runs nom build for the configured host with a visual progress monitor.
# Leaves result in the selected checkout, preserving flake.lock and requesting no sudo.
# The running system remains on its current generation.
#
# Examples:
#   kae build
def "main build" [] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.nom [build --no-update-lock-file $"path:($repository)#nixosConfigurations.($KAE_CONFIG.hostname).config.system.build.toplevel"]
}

# Build and activate syrup, using sudo for privileged activation operations.
#
# Runs nixos-rebuild switch for the configured host. This builds the system,
# creates a generation, and activates its configuration and services.
# Run kae normally: sudo elevation is handled by nixos-rebuild and may prompt
# for your password. Preserves flake.lock; no automatic tests or cleanup run.
#
# Examples:
#   kae switch
def "main switch" [] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.rebuild [switch --flake $"path:($repository)#($KAE_CONFIG.hostname)" --no-update-lock-file --elevate sudo]
}

# Update all flake inputs, or only the named inputs, in the selected checkout.
#
# Runs nix flake update. With no names, update all inputs; with names, update
# only those inputs and any required dependencies. Nix validates input names.
# This intentionally writes flake.lock without sudo. Input declarations and
# exact commit pins in flake.nix stay unchanged; a lockfile refresh alone does
# not advance exact pins such as cat-widget and mpvpaper-plugin.
# No automatic checks, builds, or activation follow the update.
#
# Examples:
#   kae update
#   kae update nixpkgs
#   kae update nixpkgs dms
def "main update" [...inputs: string # Input names; omit to update all inputs.
] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.nix ([flake update --flake $"path:($repository)" --] | append $inputs)
}

# Collect unreachable store paths. Explicit pruning removes rollback generations.
#
# By default, run nix store gc without deleting profile generations or using
# sudo. Add --older-than with a positive day period such as 14d to prune user
# profiles first, then system/root profiles through sudo, collecting garbage
# during both operations. Nix decides which profiles and generations qualify.
# Deleted generations are no longer available for rollback. User cleanup must
# succeed before system cleanup starts; a later failure cannot undo that cleanup.
# No checkout is needed. Existing weekly 14-day cleanup remains independent.
#
# Examples:
#   kae gc
#   kae gc --older-than 14d
def "main gc" [
    --older-than: string # Prune user and system/root profiles older than a positive day period, e.g. 14d.
] {
    if $older_than == null {
        execute $KAE_CONFIG.commands.nix [store gc]
    } else {
        if $older_than !~ '^[1-9][0-9]*d$' {
            error make {msg: "--older-than must be a positive number of days, e.g. 14d"}
        }
        let arguments = [--delete-older-than $older_than]
        announce $KAE_CONFIG.commands.collectGarbage $arguments
        run-external $KAE_CONFIG.commands.collectGarbage ...$arguments
        let status = $env.LAST_EXIT_CODE
        if $status != 0 { exit $status }
        execute $KAE_CONFIG.commands.sudo ([$KAE_CONFIG.commands.collectGarbage] | append $arguments)
    }
}

# Deduplicate identical files in the Nix store.
#
# Runs nix store optimise to replace identical store files with hard links.
# It does not delete profile generations or request sudo, and needs no checkout.
# Kaenix already optimizes new store paths automatically; this manually scans
# the existing store. It does not also run garbage collection.
#
# Examples:
#   kae optimize
def "main optimize" [] {
    execute $KAE_CONFIG.commands.nix [store optimise]
}

# Format Nix files using the flake formatter; paths are relative to the checkout.
#
# With no paths, format the whole repository. Supply files or directories to
# limit formatting; paths containing spaces must be quoted.
# Default mode rewrites Nix files with the flake formatter. --check uses a pinned
# read-only formatter variant, changes no source files, and exits nonzero if
# formatting is needed. Both modes preserve flake.lock and request no sudo.
# Formatting covers Nix files, not Nushell scripts.
#
# Examples:
#   kae fmt
#   kae fmt flake.nix parts/features/shell
#   kae fmt --check
#   kae fmt --check flake.nix
def "main fmt" [
    --check # Check formatting without modifying files.
    ...paths: string # Files or directories; omit to format the whole repository.
] {
    let repository = (enter-repository)
    if $check {
        # treefmt --ci alone rewrites files. This pinned variant supplies
        # nixfmt --check so both whole-tree and selected checks are read-only.
        execute $KAE_CONFIG.commands.formatterCheck ([--ci --tree-root $repository] | append $paths)
    } else {
        execute $KAE_CONFIG.commands.nix ([fmt --no-update-lock-file --override-flake . $"path:($repository)" --] | append $paths)
    }
}
