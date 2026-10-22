{ ... }:
{
  flake.modules.nixos.nushell =
    { pkgs, globals, ... }:
    {
      programs.nushell.enable = true;
      environment.shells = [ pkgs.nushell ];
      home-manager.users.${globals.username} =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          loginEnvironment = pkgs.writeShellScript "kaenix-nushell-login-environment" ''
            set -e
            # POSIX profiles must be interpreted by Bash, not Nushell. Keep stdout
            # reserved for the NUL-delimited environment, even if a profile prints text.
            if [ -r /etc/profile ]; then
              . /etc/profile > /dev/null
            fi
            . ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh > /dev/null
            exec ${pkgs.coreutils}/bin/env --null
          '';
        in
        {
          programs.nushell = {
            enable = true;
            settings = {
              show_banner = false;
              shell_integration = {
                osc7 = true;
                osc133 = true;
              };
            };
            # Keep Nu's structured `ls`; use ll for the external eza view.
            shellAliases.ll = "${lib.getExe pkgs.eza} --icons --group-directories-first -l";
            # Preserve the greeting's position before Starship's startup integration.
            extraConfig = lib.mkBefore ''
              if $nu.is-interactive {
                ^${lib.getExe pkgs.fastfetch}
              }
            '';
            extraLogin = ''
              use ${../../scripts/import-login-env.nu} load-posix-env
              load-posix-env [
                "${pkgs.bash}/bin/bash" "--noprofile" "--norc" "${loginEnvironment}"
              ]
            '';
          };
        };
    };
}
