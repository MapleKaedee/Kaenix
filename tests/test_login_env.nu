use std/assert
use ../scripts/import-login-env.nu load-posix-env

let original_directory = $env.PWD
let original_shell = $env.SHELL?
let value = "first=second\nthird"

load-posix-env [
    env --ignore-environment --null
    "PATH=/first:/second"
    "PWD=/must-not-change-directory"
    "BROWSER=brave"
    $"KAENIX_TEST_VALUE=($value)"
]
assert equal $env.PATH [/first /second]
assert equal $env.BROWSER brave
assert equal $env.KAENIX_TEST_VALUE $value
assert equal $env.PWD $original_directory
assert equal $env.SHELL? $original_shell

# A failed profile must not replace the caller's environment with partial output.
let rejected = (try {
    load-posix-env [/bin/sh -c 'exit 19']
    false
} catch { true })
assert $rejected
assert equal $env.PWD $original_directory
