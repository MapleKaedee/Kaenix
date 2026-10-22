{ globals, ... }:
{
  home-manager.users.${globals.username} = {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "TTY";
        theme_background = false;
      };
    };
  };
}
