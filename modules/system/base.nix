{ ... }:
{
  flake.modules.nixos.base =
    { ... }:
    {
      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };
    };
}
