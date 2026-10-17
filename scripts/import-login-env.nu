# Import exported POSIX variables without evaluating shell text in Nushell.
export def --env load-posix-env [command: list<string>] {
    let result = (run-external ...$command | complete)
    if $result.exit_code != 0 {
        error make {msg: "Failed to load the POSIX login environment", help: $result.stderr}
    }
    let imported = (
        $result.stdout
        | split row (char nul)
        | where {|entry| $entry != "" }
        | parse --regex '(?s)^(?<name>[^=]+)=(?<value>.*)$'
        | where {|entry| $entry.name not-in [PWD OLDPWD SHLVL _ FILE_PWD CURRENT_FILE] }
        | transpose --header-row --as-record
    )
    load-env (
        $imported
        | upsert PATH { $imported.PATH | split row (char esep) }
    )
}
