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
        memoryPercent = 100;
        priority = 100;
      };

      boot.kernelParams = [ "zswap.enabled=0" ];
      boot.kernel.sysctl = {
        # Prefer compressed anonymous pages over reclaiming the file cache.
        "vm.swappiness" = 150;
        "vm.vfs_cache_pressure" = 50;

        # Bound dirty page writeback and disable swap read-ahead for ZRAM.
        "vm.dirty_bytes" = 268435456;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.page-cluster" = 0;
      };

      services.udev.extraRules = ''
        ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
        ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
      '';
    };
}
