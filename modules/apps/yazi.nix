{ globals, ... }:
{
  home-manager.users.${globals.username} = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableFishIntegration = true;
      enableNushellIntegration = true;
      settings.mgr = {
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };
}
