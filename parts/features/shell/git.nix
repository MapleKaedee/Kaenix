{ ... }:
{
  flake.modules.nixos.git =
    { globals, ... }:
    {
      home-manager.users.${globals.username} =
        { pkgs, globals, ... }:
        {
          programs.git = {
            enable = true;
            settings = {
              user = {
                name = globals.username;
                email = "maplemepuruu@gmail.com";
              };
              # gh cannot write helpers into Home Manager's read-only Git config.
              credential = {
                "https://github.com".helper = [
                  ""
                  "${pkgs.gh}/bin/gh auth git-credential"
                ];
                "https://gist.github.com".helper = [
                  ""
                  "${pkgs.gh}/bin/gh auth git-credential"
                ];
              };
            };
          };
        };
    };
}
