{ pkgs, homeConfig }:
{
  terminal-apps =
    pkgs.runCommand "kaenix-terminal-apps-test"
      {
        nativeBuildInputs = [
          pkgs.python3
          homeConfig.programs.btop.package
          homeConfig.programs.helix.package
          homeConfig.programs.yazi.package
        ];
        btopConfig = homeConfig.xdg.configFile."btop/btop.conf".source;
        helixConfig = homeConfig.xdg.configFile."helix/config.toml".source;
        yaziConfig = homeConfig.xdg.configFile."yazi/yazi.toml".source;
      }
      ''
        export HOME="$TMPDIR/test-home"
        export XDG_CONFIG_HOME="$HOME/.config"
        mkdir -p "$XDG_CONFIG_HOME"
        python3 ${./test_terminal_apps.py}
        touch "$out"
      '';

  terminals =
    let
      probe =
        mode:
        pkgs.writeShellScriptBin (if mode == "--probe" then "tuios" else "shell") ''
          exec ${pkgs.python3}/bin/python3 ${./test_terminal_session.py} ${mode} "$@"
        '';
      testLauncher =
        shell:
        import ../lib/terminal-session.nix {
          inherit (pkgs) lib;
          inherit pkgs shell;
          tuios = probe "--probe";
        };
    in
    pkgs.runCommand "kaenix-terminals-test"
      {
        nativeBuildInputs = [
          pkgs.python3
          homeConfig.xdg.terminal-exec.package
          homeConfig.programs.alacritty.package
          homeConfig.programs.kitty.package
        ];
        alacrittyConfig = homeConfig.xdg.configFile."alacritty/alacritty.toml".source;
        terminalList = homeConfig.xdg.configFile."xdg-terminals.list".source;
        shellProgram = homeConfig.programs.kitty.settings.shell;
        sessionLaunchers = builtins.toJSON {
          fish = {
            launcher = testLauncher pkgs.fish;
            shell = pkgs.lib.getExe pkgs.fish;
          };
          nushell = {
            launcher = testLauncher pkgs.nushell;
            shell = pkgs.lib.getExe pkgs.nushell;
          };
          probe = {
            launcher = testLauncher (probe "--shell-probe");
          };
        };
        themePath = "${homeConfig.xdg.configHome}/alacritty/dank-theme.toml";
        themeSeed = ../config/alacritty/dank-theme.toml;
        terminalDataDirs = "${homeConfig.programs.alacritty.package}/share:${homeConfig.programs.kitty.package}/share";
        terminalPackages = builtins.toJSON {
          "Alacritty.desktop" = "${homeConfig.programs.alacritty.package}/bin/alacritty";
          "kitty.desktop" = "${homeConfig.programs.kitty.package}/bin/kitty";
        };
      }
      ''
        export HOME="$TMPDIR/test-home"
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CACHE_HOME="$HOME/.cache"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_DATA_DIRS="$terminalDataDirs"
        export XDG_CONFIG_DIRS="$TMPDIR/empty-config"
        export XDG_CURRENT_DESKTOP=niri
        export XTE_CACHE_ENABLED=0
        python3 ${./test_terminals.py}
        python3 ${./test_terminal_session.py}
        touch "$out"
      '';

  mpv-config =
    pkgs.runCommand "kaenix-mpv-config-test"
      {
        nativeBuildInputs = [
          homeConfig.programs.mpv.finalPackage
          pkgs.ffmpeg
          pkgs.python3
        ];
        mpvAssets = ../config/mpv;
        mpvDeployment = pkgs.linkFarm "kaenix-mpv-deployed-config" (
          pkgs.lib.mapAttrsToList (name: file: {
            name = pkgs.lib.removePrefix "mpv/" name;
            path = file.source;
          }) (pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "mpv/" name) homeConfig.xdg.configFile)
        );
        mimeDefaults = pkgs.writeText "kaenix-mpv-mime.json" (
          builtins.toJSON homeConfig.xdg.mimeApps.defaultApplications
        );
      }
      ''
        python3 ${./test_mpv.py}
        touch "$out"
      '';

  shells =
    pkgs.runCommand "kaenix-shells-test"
      {
        nativeBuildInputs = [
          pkgs.nushell
          pkgs.fish
          pkgs.coreutils
          pkgs.gnugrep
        ];
      }
      ''
        export HOME="$TMPDIR/test-home"
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_STATE_HOME="$HOME/.local/state"
        export XDG_CACHE_HOME="$HOME/.cache"
        export TERM=xterm-256color
        export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
        mkdir -p "$XDG_CONFIG_HOME/nushell" "$XDG_CONFIG_HOME/fastfetch" scripts tests
        cp ${../scripts/import-login-env.nu} scripts/import-login-env.nu
        cp ${./test_login_env.nu} tests/test_login_env.nu
        nu --no-config-file tests/test_login_env.nu

        cp ${
          homeConfig.home.file."${homeConfig.programs.nushell.configDir}/config.nu".source
        } "$XDG_CONFIG_HOME/nushell/config.nu"
        cp ${
          homeConfig.home.file."${homeConfig.programs.nushell.configDir}/login.nu".source
        } "$XDG_CONFIG_HOME/nushell/login.nu"
        cp ${homeConfig.home.file.${homeConfig.programs.starship.configPath}.source} "$STARSHIP_CONFIG"
        cp ${
          homeConfig.xdg.configFile."fastfetch/config.jsonc".source
        } "$XDG_CONFIG_HOME/fastfetch/config.jsonc"
        cp ${../config/fastfetch/hakufetch.txt} "$XDG_CONFIG_HOME/fastfetch/hakufetch.txt"
        fish --no-execute ${homeConfig.xdg.configFile."fish/config.fish".source}
        ${pkgs.lib.concatMapStringsSep "\n"
          (name: ''
            mkdir -p "$XDG_CONFIG_HOME/$(dirname ${pkgs.lib.escapeShellArg name})"
            cp ${homeConfig.xdg.configFile.${name}.source} "$XDG_CONFIG_HOME/"${pkgs.lib.escapeShellArg name}
          '')
          (
            builtins.filter (name: pkgs.lib.hasPrefix "fish/" name) (
              builtins.attrNames homeConfig.xdg.configFile
            )
          )
        }
        fish --interactive --command '
          # The generated session variables point to the configured real home.
          # Keep this smoke test inside its temporary home instead.
          set -gx XDG_CONFIG_HOME "$HOME/.config"
          set -gx XDG_CACHE_HOME "$HOME/.cache"
          set -gx XDG_DATA_HOME "$HOME/.local/share"
          set -gx XDG_STATE_HOME "$HOME/.local/state"
          set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship.toml"
          functions --query fish_prompt; or exit 1
          functions --query y; or exit 1
          test "$STARSHIP_SHELL" = fish; or exit 1
          fish_greeting
          echo kaenix-fish
        ' > fish.out
        test "$(grep -c 'Maple-Tree' fish.out)" = 1
        grep -q '^kaenix-fish$' fish.out

        # A forced config also has to stay quiet for noninteractive commands.
        nu --config "$XDG_CONFIG_HOME/nushell/config.nu" -c 'print "kaenix-quiet"' > quiet.out
        test "$(cat quiet.out)" = kaenix-quiet
        nu --login -c 'use std/assert; assert equal $env.BROWSER brave; assert (($env.PATH | describe) == "list<string>"); print "kaenix-login"' > login.out
        test "$(cat login.out)" = kaenix-login
        nu --interactive --config "$XDG_CONFIG_HOME/nushell/config.nu" -c 'use std/assert; assert equal (ls | describe | str starts-with "table") true; assert (scope aliases | any {|a| $a.name == "ll" }); assert (scope commands | any {|c| $c.name == "y" }); assert equal $env.STARSHIP_SHELL nu; print "kaenix-interactive"' > interactive.out
        test "$(grep -c 'Maple-Tree' interactive.out)" = 1
        grep -q '^kaenix-interactive$' interactive.out
        touch "$out"
      '';

  seed-files =
    pkgs.runCommand "kaenix-seed-files-test"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        mkdir -p scripts tests
        cp ${../scripts/seed-files.py} scripts/seed-files.py
        cp ${./test_seed_files.py} tests/test_seed_files.py
        python3 -m unittest discover -s tests -v
        touch "$out"
      '';

  niri-config =
    pkgs.runCommand "kaenix-niri-config-test"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        mkdir -p niri/dms
        cp ${../config/niri/config.kdl} niri/config.kdl
        # The compositor must start before DMS has generated any files.
        niri validate -c "$PWD/niri/config.kdl"
        cp ${../config/niri/dms}/*.kdl niri/dms/
        niri validate -c "$PWD/niri/config.kdl"
        touch "$out"
      '';

  seed-integration =
    pkgs.runCommand "kaenix-seed-integration-test"
      {
        nativeBuildInputs = [ pkgs.python3 ];
        manifest = pkgs.writeText "kaenix-seeds.json" (builtins.toJSON homeConfig.kaenix.seedFiles);
      }
      ''
        mkdir -p test-home
        python3 ${../scripts/seed-files.py} --home "$PWD/test-home" --manifest "$manifest"
        python3 - <<'PY'
        import json, os
        from pathlib import Path
        root = Path("test-home")
        entries = json.loads(Path(os.environ["manifest"]).read_text())
        assert len(entries) == 17
        for entry in entries:
            path = root / entry["target"]
            assert path.is_file() and not path.is_symlink(), path
            assert path.read_bytes() == Path(entry["source"]).read_bytes(), path
            if path.suffix == ".json":
                json.loads(path.read_text())
        settings = root / ".config/DankMaterialShell/settings.json"
        settings.write_text('{"fromGUI": true}')
        (root / ".config/alacritty/dank-theme.toml").write_text('[colors.primary]\nbackground = "#123456"\n')
        PY
        python3 ${../scripts/seed-files.py} --home "$PWD/test-home" --manifest "$manifest"
        python3 - <<'PY'
        import json
        from pathlib import Path
        assert json.loads(Path("test-home/.config/DankMaterialShell/settings.json").read_text()) == {"fromGUI": True}
        assert Path("test-home/.config/alacritty/dank-theme.toml").read_text() == '[colors.primary]\nbackground = "#123456"\n'
        PY
        touch "$out"
      '';
}
