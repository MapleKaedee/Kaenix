{ globals, ... }:
{
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  home-manager.users.${globals.username} =
    { pkgs, ... }:

    {
      services.udiskie = {
        enable = true;
        package = pkgs.udiskie.overrideAttrs (old: {
          # An invalidated key lookup may return ENOKEY or EKEYREVOKED.
          # Keep the test enabled and accept either unavailable-key result.
          postPatch = (old.postPatch or "") + ''
            substituteInPlace test/test_keyutils.py \
              --replace-fail 'self.assertRaises(keyutils.KeyNotAvailable)' \
                'self.assertRaises((keyutils.KeyNotAvailable, keyutils.KeyRevoked))'
          '';
        });
        automount = true;
        notify = true;
        tray = "auto";
      };
    };
}
