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
  services.tailscale.enable = true;
  services.resolved.enable = true;

  # ── Hardware & Graphics ───────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

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
    # STMicroelectronics ST-LINK/V2.1
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666"
  '';

  # ── Session Variables (Default: Docked / 4K Workstation) ──────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    KWIN_DRM_DEVICES = "/dev/dri/igpu:/dev/dri/dgpu";
    KWIN_DRM_NO_DIRECT_SCANOUT = "1";
  };

  # ── Boot Profiles (Specialisations) ───────────────────────────────────
  # "igpu" specialisation puts the NVIDIA dGPU to sleep for maximum battery life.
  specialisation = {
    igpu.configuration = {

      environment.sessionVariables = {
        KWIN_DRM_DEVICES = lib.mkForce "/dev/dri/igpu";

        __GLX_VENDOR_LIBRARY_NAME = lib.mkForce "mesa";
        __EGL_VENDOR_LIBRARY_FILENAMES = lib.mkForce "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
        VK_DRIVER_FILES = lib.mkForce "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
      };

      # Enforce power-saving CPU profile on battery for maximum mobile endurance
      services.tlp.settings = {
        CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "power";
        PLATFORM_PROFILE_ON_BAT = lib.mkForce "low-power";
      };
    };
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

      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 92;
    };
  };

  # ── Nix settings ──────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
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
        pkgs.xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = [ "kde" ];
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
  virtualisation.containers.registries.search = [ "docker.io" "quay.io" ];

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
    shell = pkgs.zsh;
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
    poppler-utils
    exfatprogs
  ];

  services.udev.packages = [ pkgs.stlink ];

  programs.kdeconnect.enable = true;
  programs.zsh.enable = true;
  
  system.stateVersion = "25.05";
}