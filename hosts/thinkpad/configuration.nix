{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "nouveau" "nvidiafb" ];

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = "lukes-nixos";
  networking.networkmanager.enable = true;
  services.netbird.enable = true;
  services.resolved.enable = true;

  # ── Locale & Time ─────────────────────────────────────────────────────
  # time.timeZone = "America/Chicago";
  # i18n.defaultLocale = "en_US.UTF-8";

  # ── Hardware & Graphics ───────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="i915", SYMLINK+="dri/igpu"
    SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="nvidia", SYMLINK+="dri/dgpu"
  '';

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
    KWIN_DRM_DEVICES = "/dev/dri/igpu:/dev/dri/dgpu";
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64 * 1024; # 64 GiB
  }];

  # ── Power Management (TLP) ────────────────────────────────────────────
  services.tuned.enable = false;
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      # Audio codec power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;

      START_CHARGE_THRESH_BAT0 = 90;
      STOP_CHARGE_THRESH_BAT0 = 95;
    };
  };

  # ── Nix settings ──────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  # ── Display manager ───────────────────────────────────────────────────
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      theme = "breeze";
      wayland.enable = true;
      enableHidpi = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];
    };

  # ── Audio ─────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ── Desktop services ──────────────────────────────────────────────────
  services.dbus.enable = true;
  security.pam.services.sddm.enableKwallet = true;
  services.upower.enable = true;
  services.fwupd.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # ── Virtualisation ───────────────────────────────────────────────────
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Creates a symlink from docker to podman
    defaultNetwork.settings.dns_enabled = true; 
  };

  # ── Security ──────────────────────────────────────────────────────────
    security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var mountActions = [
        "org.freedesktop.udisks2.encrypted-unlock",
        "org.freedesktop.udisks2.encrypted-unlock-system",
        "org.freedesktop.udisks2.filesystem-mount",
        "org.freedesktop.udisks2.filesystem-mount-system",
        "org.freedesktop.udisks2.filesystem-mount-other-seat",
        "org.freedesktop.udisks2.encrypted-unlock-other-seat"
      ];
      if (mountActions.indexOf(action.id) >= 0 && subject.local && subject.active) {
        if (subject.user == "lukem") {
          return polkit.Result.YES;
        }
        return polkit.Result.AUTH_ADMIN;
      }
    });
  '';

  # ── Users ─────────────────────────────────────────────────────────────
  users.users.lukem = {
    isNormalUser = true;
    description = "lukem";
    extraGroups = [ "networkmanager" "wheel" "storage" "video" "audio" ];
  };

  # ── System packages ────────────────────────────────────────────────────
  environment.plasma6.excludePackages = with pkgs; [ 
    kdePackages.discover 
    kdePackages.qrca
  ];
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    gnome-keyring
    ffmpegthumbnailer
    playerctl
    kdePackages.kate
    kdePackages.partitionmanager
    kdePackages.kcalc
    kdePackages.dolphin
    pciutils
    exfatprogs
  ];

  programs.kdeconnect.enable = true;
  
  system.stateVersion = "25.05";
}