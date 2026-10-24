{ ... }:
{
  flake.modules.nixos.audio =
    { inputs, ... }:
    {
      imports = [ inputs.nix-gaming.nixosModules.pipewireLowLatency ];

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        lowLatency = {
          enable = true;
          quantum = 64;
          rate = 48000;
          alsa.enable = false;
        };
      };
    };
}
