# Shared default command for desktop terminals; shell rc files stay untouched.
{
  lib,
  pkgs,
  shell,
  tuios ? pkgs.tuios,
}:
let
  shellProgram = lib.getExe shell;
  startSession = pkgs.writeShellScript "kaenix-tuios-start" ''
    # Login initialization may change directories. Restore the terminal's cwd.
    cd -- "$KAENIX_TUIOS_START_DIR" || exit 1
    unset KAENIX_TUIOS_START_DIR
    export SHELL=${lib.escapeShellArg shellProgram}
    exec ${lib.getExe tuios} new
  '';
in
pkgs.writeShellScript "kaenix-terminal-session" ''
  export SHELL=${lib.escapeShellArg shellProgram}
  # Arguments represent an explicit shell invocation, never a TUIOS session.
  if [ "$#" -gt 0 ]; then
    exec ${shellProgram} --login "$@"
  fi

  if [ "''${KAENIX_TUIOS_DISABLE:-}" = 1 ] ||
     [ -n "''${TUIOS_SESSION:-}''${TUIOS_WINDOW_ID:-}''${TUIOS_PANE_ID:-}''${TMUX:-}''${ZELLIJ:-}" ] ||
     [ -n "''${SSH_CONNECTION:-}''${SSH_CLIENT:-}''${SSH_TTY:-}" ] ||
     [ ! -t 0 ] || [ ! -t 1 ] || [ "''${TERM:-dumb}" = dumb ]; then
    exec ${shellProgram} --login
  fi

  export KAENIX_TUIOS_START_DIR="$PWD"
  # Both supported shells accept --login -c and exec. Neither gets an
  # interactive startup hook, so pane shells and nested shells cannot recurse.
  ${shellProgram} --login -c ${lib.escapeShellArg "exec ${startSession}"}
  status=$?
  unset KAENIX_TUIOS_START_DIR
  if [ "$status" -ne 0 ]; then
    echo "TUIOS exited with status $status; opening a login shell." >&2
  fi
  # Detaching or quitting leaves a useful shell in this terminal.
  exec ${shellProgram} --login
''
