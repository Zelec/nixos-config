{
  flake.nixosModules.sunshine = {
    pkgs,
    lib,
    ...
  }: {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      package = pkgs.sunshine.override {
        # Enables NVENC support
        # Obsolete workaround now that everything is merged in
        # https://github.com/NixOS/nixpkgs/issues/305891#issuecomment-2448635163
        # All that is needed to get it working now
        # https://github.com/NixOS/nixpkgs/issues/305891#issuecomment-3707474398
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
      };
    };
    services.avahi.publish = {
      enable = true;
      userServices = true;
    };
  };
}
