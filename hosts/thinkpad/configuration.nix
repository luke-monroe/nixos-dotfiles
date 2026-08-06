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

  # ── Locale & Time ─────────────────────────────────────────────────────
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Hardware ──────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  
		prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0"; 
      nvidiaBusId = "PCI:1:0:0";
    };
  };


  environment.sessionVariables = {
  NIXOS_OZONE_WL = "1";
  LIBVA_DRIVER_NAME = "iHD";
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── Nix settings ──────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  # ── Display manager ───────────────────────────────────────────────────
    services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
    };

    services.desktopManager.plasma6.enable = true;

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
  services.tuned.enable = true;
  services.fwupd.enable = true;
  
  services.udisks2.enable = true;
  services.gvfs.enable = true;

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
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    kitty
    gnome-keyring
    ffmpegthumbnailer
    playerctl
    kdePackages.kate
    kdePackages.partitionmanager
    kdePackages.kcalc
    kdePackages.dolphin
  ];

  system.stateVersion = "25.05";
}