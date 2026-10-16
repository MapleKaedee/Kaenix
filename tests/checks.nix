{ pkgs, homeConfig }:
{
  seed-files = pkgs.runCommand "kaenix-seed-files-test" {
    nativeBuildInputs = [ pkgs.python3 ];
  } ''
    mkdir -p scripts tests
    cp ${../scripts/seed-files.py} scripts/seed-files.py
    cp ${./test_seed_files.py} tests/test_seed_files.py
    python3 -m unittest discover -s tests -v
    touch "$out"
  '';

  niri-config = pkgs.runCommand "kaenix-niri-config-test" {
    nativeBuildInputs = [ pkgs.niri ];
  } ''
    mkdir -p niri/dms
    cp ${../config/niri/config.kdl} niri/config.kdl
    # The compositor must start before DMS has generated any files.
    niri validate -c "$PWD/niri/config.kdl"
    cp ${../config/niri/dms}/*.kdl niri/dms/
    niri validate -c "$PWD/niri/config.kdl"
    touch "$out"
  '';

  seed-integration = pkgs.runCommand "kaenix-seed-integration-test" {
    nativeBuildInputs = [ pkgs.python3 ];
    manifest = pkgs.writeText "kaenix-seeds.json" (builtins.toJSON homeConfig.kaenix.seedFiles);
  } ''
    mkdir -p test-home
    python3 ${../scripts/seed-files.py} --home "$PWD/test-home" --manifest "$manifest"
    python3 - <<'PY'
    import json, os
    from pathlib import Path
    root = Path("test-home")
    entries = json.loads(Path(os.environ["manifest"]).read_text())
    assert len(entries) == 16
    for entry in entries:
        path = root / entry["target"]
        assert path.is_file() and not path.is_symlink(), path
        assert path.read_bytes() == Path(entry["source"]).read_bytes(), path
        if path.suffix == ".json":
            json.loads(path.read_text())
    settings = root / ".config/DankMaterialShell/settings.json"
    settings.write_text('{"fromGUI": true}')
    PY
    python3 ${../scripts/seed-files.py} --home "$PWD/test-home" --manifest "$manifest"
    python3 - <<'PY'
    import json
    from pathlib import Path
    assert json.loads(Path("test-home/.config/DankMaterialShell/settings.json").read_text()) == {"fromGUI": True}
    PY
    touch "$out"
  '';
}
