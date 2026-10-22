{ ... }:
{
  flake.modules.nixos.asus =
    { ... }:
    {
      # The pinned asusctl package includes ROG Control Center and its desktop entry.
      services.asusd.enable = true;
    };
}
