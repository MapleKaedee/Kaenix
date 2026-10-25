{ pkgs, homeConfig }:
{
  kae = import ./kae.nix { inherit pkgs; };

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
    pkgs.runCommand "kaenix-terminals-test"
      {
        nativeBuildInputs = [
          pkgs.python3
          homeConfig.xdg.terminal-exec.package
          homeConfig.programs.alacritty.package
          homeConfig.programs.kitty.package
        ];
        alacrittyConfig = homeConfig.xdg.configFile."alacritty/alacritty.toml".source;
        kittyConfig = homeConfig.xdg.configFile."kitty/kitty.conf".source;
        terminalList = homeConfig.xdg.configFile."xdg-terminals.list".source;
        shellProgram = homeConfig.programs.alacritty.settings.terminal.shell.program;
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

  mango-config =
    pkgs.runCommand "kaenix-mango-config-test"
      {
        nativeBuildInputs = [ pkgs.mango ];
        mangoConfig = homeConfig.xdg.configFile."mango/config.conf".source;
      }
      ''
        export HOME="$TMPDIR/test-home"
        mkdir -p "$HOME/.config/mango/dms"
        cp "$mangoConfig" "$HOME/.config/mango/config.conf"
        cp ${../config/mango/dms}/*.conf "$HOME/.config/mango/dms/"
        test -f ${pkgs.mango}/share/systemd/user/mango-session.target
        mango -c "$HOME/.config/mango/config.conf" -p
        touch "$out"
      '';

  seed-integration =
    pkgs.runCommand "kaenix-seed-integration-test"
      {
        nativeBuildInputs = [ pkgs.python3 ];
        manifest = pkgs.writeText "kaenix-seeds.json" (builtins.toJSON homeConfig.kaenix.seedFiles);
        dmsThemePath = "${homeConfig.xdg.configHome}/dms/themes/catppuccin/theme.json";
      }
      ''
        mkdir -p test-home migrated-home
        python3 - <<'PY'
        import json
        from pathlib import Path
        root = Path("migrated-home")
        preserved = {
            ".config/dms/settings.json": '{"fromGUI": true}',
            ".config/dms/plugin_settings.json": '{"customPlugin": true}',
            ".local/state/dms/session.json": '{"customSession": true}',
            ".config/dms/themes/catppuccin/theme.json": '{"customTheme": true}',
        }
        for relative, contents in preserved.items():
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(contents)
        for base in (".config", ".local/state"):
            (root / base / "DankMaterialShell").symlink_to("dms", target_is_directory=True)
        Path("migrated-expected.json").write_text(json.dumps(preserved))
        PY
        python3 ${../scripts/seed-files.py} --home "$PWD/migrated-home" --manifest "$manifest"
        python3 - <<'PY'
        import json
        from pathlib import Path
        root = Path("migrated-home")
        for relative, contents in json.loads(Path("migrated-expected.json").read_text()).items():
            target = root / relative
            assert not target.is_symlink(), relative
            assert target.read_text() == contents, relative
        for base in (".config", ".local/state"):
            assert (root / base / "DankMaterialShell").readlink() == Path("dms")
            assert not (root / base / "dms").is_symlink()
        PY
        python3 ${../scripts/seed-files.py} --home "$PWD/test-home" --manifest "$manifest"
        python3 - <<'PY'
        import json, os
        from pathlib import Path
        root = Path("test-home")
        entries = json.loads(Path(os.environ["manifest"]).read_text())
        assert len(entries) == 24
        assert {entry["target"] for entry in entries if entry["target"].startswith((".config/dms/", ".local/state/dms/"))} == {
            ".config/dms/settings.json",
            ".config/dms/plugin_settings.json",
            ".local/state/dms/session.json",
            ".config/dms/themes/catppuccin/theme.json",
        }
        assert all("/DankMaterialShell/" not in entry["target"] for entry in entries)
        for entry in entries:
            path = root / entry["target"]
            assert path.is_file() and not path.is_symlink(), path
            assert path.read_bytes() == Path(entry["source"]).read_bytes(), path
            if path.suffix == ".json":
                json.loads(path.read_text())
        settings = root / ".config/dms/settings.json"
        assert json.loads(settings.read_text())["customThemeFile"] == os.environ["dmsThemePath"]
        settings.write_text('{"fromGUI": true}')
        (root / ".config/alacritty/dank-theme.toml").write_text('[colors.primary]\nbackground = "#123456"\n')
        mango_binds = root / ".config/mango/dms/binds.conf"
        mango_binds.write_text("# edited in DMS\n")
        PY
        python3 ${../scripts/seed-files.py} --home "$PWD/test-home" --manifest "$manifest"
        python3 - <<'PY'
        import json
        from pathlib import Path
        assert json.loads(Path("test-home/.config/dms/settings.json").read_text()) == {"fromGUI": True}
        assert Path("test-home/.config/alacritty/dank-theme.toml").read_text() == '[colors.primary]\nbackground = "#123456"\n'
        assert Path("test-home/.config/mango/dms/binds.conf").read_text() == "# edited in DMS\n"
        PY
        touch "$out"
      '';
}
