{ ... }:
{
  security.polkit.enable = true;
  # DMS supplies the session's authentication agent.
  services.accounts-daemon.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
