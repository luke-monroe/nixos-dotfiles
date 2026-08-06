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
  time.timeZone = "America/Detroit";
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
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    # WLR_NO_HARDWARE_CURSORS = "1";
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # ── Nix settings ──────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  # ── Hyprland / Wayland ────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.uwsm.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ── Display manager ───────────────────────────────────────────────────
  services.greetd = {
    enable = true;
    settings.default_session = {
      # auto login
      # user = "lukem";
      # command = "start-hyprland"; 
      # manual login
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session -s start-hyprland";
      user = "greeter";
    };
  };

  # ── Audio ─────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ── Desktop services ──────────────────────────────────────────────────
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;
  services.tuned.enable = true;
  
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # ── Security ──────────────────────────────────────────────────────────
  security.pam.services.greetd.enableGnomeKeyring = true;
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
    uwsm
    kitty
    polkit_gnome
    gnome-keyring
    nemo
    ffmpegthumbnailer
		file-roller
    nemo-fileroller
    nemo-python
    gnome-desktop
    noctalia-qs
    playerctl
  ];

  system.stateVersion = "25.05";
}