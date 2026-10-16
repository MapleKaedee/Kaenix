{ globals, ... }:
{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/${globals.username}";
  };
  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin.enable = false;
  security.polkit.enable = true;
  # DMS supplies the session's authentication agent.
  services.accounts-daemon.enable = true;
  services.upower.enable = true;
  hardware.bluetooth.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.dankshell = { };
}
