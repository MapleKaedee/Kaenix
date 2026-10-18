{ globals, ... }:
{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/${globals.username}";
  };
  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin.enable = false;
  security.pam.services.dankshell = { };
  home-manager.users.${globals.username}.imports = [ ./home.nix ];
}
