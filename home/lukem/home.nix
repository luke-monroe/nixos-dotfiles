#home.nix
{ config, pkgs, inputs, lib, ... }:

{
  home.username = "lukem";
  home.homeDirectory = "/home/lukem";
  home.stateVersion = "25.05";

	programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      continue.continue
    ];
  };
  home.packages = with pkgs; [
    # browsers
    firefox
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser
    chromium

    # dev tools
		nodejs
    tailscale
    ollama
    podman
    distrobox

    # media
    spotify
    librepods
    discord
    
    davinci-resolve
    video-downloader
    yt-dlp
    yt-dlg
    vlc
    handbrake
    libreoffice

    # utilities
    incron
    ffmpeg

    # kde apps
    kdePackages.kclock
    kdePackages.isoimagewriter
    # these apps are already included with plasma
    #kdePackages.dolphin
    #kdePackages.dolphin-plugins
    #kdePackages.baloo-widgets
    #kdePackages.kate
    #kdePackages.kcalc
    #kdePackages.ktexteditor
    #kdePackages.konsole
    #kdePackages.kwin-x11
    #kdePackages.elisa
    #kdePackages.gwenview
    #kdePackages.okular
    #kdePackages.ffmpegthumbs
    #kdePackages.ark
    #kdePackages.spectacle
    #kdePackages.krdp
    #kdePackages.partitionmanager
    #kdePackages.system-monitor
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      nix-a = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
      nix-u = "nix flake update \n
               sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
    };
		initExtra = ''
		  # echo git config on start
			[[ $- == *i* ]] && {
				echo "Git profile:"
				git config user.email
			}

		'';
	};
  programs.bash.bashrcExtra = ''
    dgpu() {
      local nv intel
      for c in /dev/dri/card*; do
        case "$(cat /sys/class/drm/$(basename "$c")/device/vendor 2>/dev/null)" in
          0x10de) nv=$c ;;
          0x8086) intel=$c ;;
        esac
      done
      mkdir -p ~/.config/plasma-workspace/env
      echo "export KWIN_DRM_DEVICES=\"$nv:$intel\"" > ~/.config/plasma-workspace/env/kwin-gpu.sh
      chmod +x ~/.config/plasma-workspace/env/kwin-gpu.sh
      echo "NVIDIA set primary ($nv). Log out/in to apply."
    }

    igpu() {
      rm -f ~/.config/plasma-workspace/env/kwin-gpu.sh
      echo "Intel set primary (default). Log out/in to apply."
    }

    gpu-status() {
      echo "=== Configuration ==="

      if [ -f ~/.config/plasma-workspace/env/kwin-gpu.sh ]; then
        echo "KWin DRM: NVIDIA primary"
        cat ~/.config/plasma-workspace/env/kwin-gpu.sh
      else
        echo "KWin DRM: default"
      fi

      echo
      echo "=== DRM devices ==="
      for c in /dev/dri/card*; do
        echo "$c"
        echo "  vendor: $(cat /sys/class/drm/$(basename "$c")/device/vendor 2>/dev/null)"
        echo "  device: $(cat /sys/class/drm/$(basename "$c")/device/device 2>/dev/null)"
      done

      echo
      echo "=== KWin ==="
      qdbus org.kde.KWin /KWin supportInformation |
        grep -E "OpenGL vendor|OpenGL renderer|OpenGL version|Driver|Xwayland|Compositing"

      echo
      echo "=== NVIDIA ==="
      nvidia-smi --query-gpu=name,driver_version,pstate,temperature.gpu,memory.used \
        --format=csv,noheader
    }
  '';
}
