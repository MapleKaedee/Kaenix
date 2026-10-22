{ globals, ... }:
{
  home-manager.users.${globals.username} = {
    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "base16_transparent";
        editor = {
          line-number = "relative";
          color-modes = true;
        };
      };
    };
  };
}
