{
  flake.nixosModules.hunspell = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      (hunspell.withDicts (
        dict: [
          dict.en_CA-large
          dict.en_US-large
          dict.en_GB-large
        ]
      ))
    ];
  };
}
