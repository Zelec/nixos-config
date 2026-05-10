{inputs, ...}: {
  imports = [
    # currently unused
    # inputs.flake-parts.flakeModules.modules
  ];
  config = {
    systems = [
      "x86_64-linux"
      # I'd love to get my Raspberry Pi 5 working in here, but I have to do more digging
      # Last time I tried used a UEFI bootloader off the SD card that worked okay-ish, but it didn't end up working well in the long run.
      "aarch64-linux"
      # I don't own any macs so having them declared as options makes no sense
      # "x86_64-darwin"
      # "aarch64-darwin"
    ];
  };
}
