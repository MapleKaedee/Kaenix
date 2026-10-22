{ pkgs }:
let
  stub =
    mode:
    pkgs.writeShellScript "kae-test-${mode}" ''
      exec ${pkgs.python3}/bin/python3 ${./test_kae.py} --stub ${mode} "$@"
    '';
  commands = {
    nix = stub "nix";
    nom = stub "nom";
    rebuild = stub "rebuild";
    collectGarbage = stub "collectGarbage";
    sudo = stub "sudo";
    formatterCheck = stub "formatterCheck";
  };
  kae = import ../lib/kae.nix {
    inherit pkgs commands;
    repository = "/kaenix-test-missing-default";
  };
in
pkgs.runCommand "kaenix-kae-test"
  {
    nativeBuildInputs = [ pkgs.python3 ];
    KAE_TEST_BIN = "${kae}/bin/kae";
    KAE_TEST_COLLECT_GARBAGE = commands.collectGarbage;
    KAE_TEST_CHECK_FORMATTER = "${
      pkgs.nixfmt-tree.override { settings.formatter.nixfmt.options = [ "--check" ]; }
    }/bin/treefmt";
    KAE_TEST_FORMATTER = "${pkgs.nixfmt-tree}/bin/treefmt";
  }
  ''
    export HOME="$TMPDIR/test-home"
    export XDG_CONFIG_HOME="$HOME/.config"
    mkdir -p "$XDG_CONFIG_HOME"
    python3 ${./test_kae.py}
    touch "$out"
  ''
