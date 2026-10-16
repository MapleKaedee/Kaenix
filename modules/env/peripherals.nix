# Printing and audio (PipeWire) configuration
{ ... }:
{
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # The pinned asusctl package includes rog-control-center and its desktop entry.
  services.asusd.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.opentabletdriver.enable = true;
}
