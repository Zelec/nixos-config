{inputs, ...}: {
  flake.nixosModules.hostAmethyst = {pkgs, ...}: {
    users.groups."actions" = {};
    users.users."actions" = {
      isSystemUser = true;
      hashedPassword = "!";
      shell = pkgs.bash;
      packages = with pkgs; [
        docker
        docker-compose
      ];
      group = "actions";
      linger = true;
      extraGroups = [
        "docker"
      ];
      openssh.authorizedKeys = {
        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA34xSRil5y/9f61fRfMQLBXyYroco+zKx9qLjfoflFR git.tgdev.net/zelec/docs - actions key"
        ];
        keyFiles = [
          inputs.ssh-keys.outPath
        ];
      };
    };
  };
}
