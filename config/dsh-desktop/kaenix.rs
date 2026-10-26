//! Package-local policy, before Tauri or any upstream startup side effect.
//! This also runs when current_exe() is restarted or the ELF is invoked directly.
use std::fs::{File, OpenOptions};
use std::os::unix::fs::{MetadataExt, OpenOptionsExt};
use std::process::Command;
use std::sync::OnceLock;

const HELPER: &str = "@kaenixHelper@";
const BACKEND: &str = "@kaenixBackend@";
static RUNTIME_LOCK: OnceLock<File> = OnceLock::new();

pub fn backend() -> &'static str {
    BACKEND
}

fn helper(operation: &str) -> Command {
    let mut command = Command::new(HELPER);
    command.args(["--backend-launcher", BACKEND, operation]);
    command
}

fn prepare() -> Result<(), String> {
    let output = helper("context")
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).trim().to_string());
    }
    let context: serde_json::Value =
        serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())?;
    let environment = context["environment"]
        .as_object()
        .ok_or("invalid launch environment")?;
    // Do not leave uppercase aliases able to override the private npm settings.
    for (key, _) in std::env::vars_os() {
        if key
            .to_string_lossy()
            .to_ascii_lowercase()
            .starts_with("npm_config_")
        {
            std::env::remove_var(key);
        }
    }
    for (key, value) in environment {
        std::env::set_var(key, value.as_str().ok_or("invalid environment value")?);
    }
    let path = context["lock"].as_str().ok_or("missing runtime lock")?;
    let file = OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .mode(0o600)
        .custom_flags(libc::O_NOFOLLOW | libc::O_CLOEXEC)
        .open(path)
        .map_err(|error| format!("cannot open runtime lock: {error}"))?;
    let metadata = file.metadata().map_err(|error| error.to_string())?;
    if !metadata.is_file() || metadata.uid() != unsafe { libc::getuid() } || metadata.nlink() != 1 {
        return Err("unsafe runtime lock".into());
    }
    use std::os::fd::AsRawFd;
    if unsafe { libc::flock(file.as_raw_fd(), libc::LOCK_SH | libc::LOCK_NB) } != 0 {
        return Err("backend setup is running; retry after it finishes".into());
    }
    RUNTIME_LOCK
        .set(file)
        .map_err(|_| "runtime was already initialized")?;
    let output = helper("check")
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).trim().to_string());
    }
    Ok(())
}

pub fn init() {
    if let Err(error) = prepare() {
        eprintln!("dsh-desktop: {error}");
        std::process::exit(1);
    }
    // A deliberately headless path: validates the same initialization used by
    // direct ELF, desktop-entry and restart launches, without touching Tauri.
    if std::env::args().any(|argument| argument == "--kaenix-check-runtime") {
        println!("DSH Desktop isolated runtime is ready.");
        std::process::exit(0);
    }
}
