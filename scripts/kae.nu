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

# Manage the Kaenix checkout. Set KAE_REPO to override its default location.
def main [] {
    print (help main | str replace --all 'main ' 'kae ')
}

# Show general help or help for one command.
def "main help" [command?: string] {
    let commands = [check test build switch gc optimize fmt help]
    if $command == null {
        print (help main | str replace --all 'main ' 'kae ')
    } else if $command in $commands {
        print (help $"main ($command)" | str replace --all 'main ' 'kae ')
    } else {
        error make {msg: $"Unknown kae command: ($command)"}
    }
}

# Evaluate the flake without building its checks or activating a configuration.
def "main check" [] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.nix [flake check --no-build --no-update-lock-file $"path:($repository)"]
}

# Build named validation checks, or all available checks when none are named.
def "main test" [...checks: string] {
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
def "main build" [] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.rebuild [build --flake $"path:($repository)#($KAE_CONFIG.hostname)" --no-update-lock-file]
}

# Build and activate syrup, using sudo for privileged activation operations.
def "main switch" [] {
    let repository = (enter-repository)
    execute $KAE_CONFIG.commands.rebuild [switch --flake $"path:($repository)#($KAE_CONFIG.hostname)" --no-update-lock-file --elevate sudo]
}

# Collect unreachable store paths. Explicit pruning removes rollback generations.
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
def "main optimize" [] {
    execute $KAE_CONFIG.commands.nix [store optimise]
}

# Format Nix files using the flake formatter; paths are relative to the checkout.
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
