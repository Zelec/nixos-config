#
# TimeWarp.timeguard.ca
# Lenovo T470 Thinkpad
# i5-7300u
# Intel HD 620 Graphics (Gen 9.5 Kaby Lake)

{ config, lib, pkgs, unstablePkgs, nixos-06cb-009a-fingerprint-sensor, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/nix-common.nix
    ../common/packages/common-pkg.nix
    ../common/services/btrfs-scrub.nix
    ../common/services/flatpak.nix
    ../common/services/openssh.nix
    ../common/services/pipewire.nix
    ../common/services/syncthing.nix
    ../common/virtualisation/docker.nix
    ../common/virtualisation/libvirt.nix
  ];

  system.stateVersion = "23.11";
  # system.copySystemConfiguration = true;
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  sound.enable = true;
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # Newer LibVA iHD driver
        intel-vaapi-driver # Older LibVA i915 driver
        libvdpau-va-gl # VDPau to LibVA Translation Layer
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
  boot = {
    resumeDevice = "/dev/TimeWarp-vg/swap";
    loader = {
      # Systemd boot for quick & simple booting
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0; # Disable bootup prompt unless Spacebar is held
   };
    initrd = {
      # Allows FDE by LVM over LUKS
      luks.devices = {
        cryptroot = {
          device = "/dev/disk/by-uuid/20603020-31bc-476a-80aa-cf69c5dbd626";
          allowDiscards = true;
        };
      };
      systemd.enable = true;
      kernelModules = [ 
        "i915"
        # "acpi_call"
      ];
    };
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    kernelParams = [
      "quiet"
      "udev.log_level=0"
      "splash"
      "i915.enable_guc=3"
      "i915.enable_fbc=1"
      # Disable "Panel Self Refresh".  Fix random freezes.
      "i915.enable_psr=0"
      "i915.fastboot=1"
    ];
  };

  fileSystems = {
    # systemd-boot will freakout if umask/fmask aren't set to disallow normal users from reading the seed files
    "/boot".options =      ["fmask=0077" "umask=0077"];
    "/".options =          ["rw" "noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15" "subvol=@rootfs"];
    "/home".options =      ["rw" "noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15" "subvol=@home"];
    "/var/cache".options = ["rw" "noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15" "subvol=@cache"];
    "/var/log".options =   ["rw" "noatime" "compress-force=zstd:1" "ssd" "space_cache=v2" "commit=15" "subvol=@logs"];
  };
  swapDevices = [{ 
    device = "/dev/TimeWarp-vg/swap";
  }];

  networking = {
    hostName = "TimeWarp";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };
  time.timeZone = "America/Toronto";

  users = {
    users.zelec = {
      description = "Isaac Towns";
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "kvm" ];
      # packages = with pkgs; [
      #  
      # ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      helvum
      libfprint-2-tod1-vfs0090
      libportal-qt5
      libsForQt5.discover
      libsForQt5.packagekit-qt
      moonlight-qt
      nixos-bgrt-plymouth
      onedrive
      onedrivegui
      papirus-icon-theme
      pavucontrol
      plasma-pa
      plymouth
      vulkan-loader
      vulkan-tools

      unstablePkgs.vscode
    ];
    sessionVariables = {
      # LIBVA_DRIVER_NAME = "iHD"; # intel-media-driver
      LIBVA_DRIVER_NAME = "i915"; # intel-vaapi-driver
      VDPAU_DRIVER = "va_gl";
    };
    etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };
  };

  xdg.portal.wlr.enable = true;
  security = {
    pam.services.sudo.fprintAuth = true;
    rtkit.enable = true;
  };
  programs = {
    virt-manager.enable = true;
    ssh.startAgent = true;
    bash.enableCompletion = true;
  };
  services = {
    fwupd.enable = true;
    open-fprintd.enable = true;
    python-validity.enable = true;
    fstrim.enable = true;
    printing.enable = true;
    resolved = {
      enable = true;
      fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
    };
    xserver = {
      enable = true;
      libinput.enable = true;
      displayManager = {
        sddm.enable = true;
        autoLogin.enable = true;
        autoLogin.user = "zelec"; 
      };
      desktopManager.plasma5.enable = true;
    };
  };
  virtualisation.docker.storageDriver = "btrfs";
}

