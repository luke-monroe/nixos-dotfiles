#home.nix
{ config, pkgs, inputs, lib, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./plasma.nix
  ];

  home.username = "lukem";
  home.homeDirectory = "/home/lukem";
  home.stateVersion = "25.05";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = [ "kde" ];
  };

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
    ollama
    podman
    distrobox
    pkgs-unstable.antigravity-ide
    cursor-cli
    code-cursor

    # media
    spotify
    librepods
    discord

    libreoffice
    onlyoffice-desktopeditors
    obsidian
    
    davinci-resolve
    video-downloader
    yt-dlp
    yt-dlg
    vlc
    handbrake
    remmina

    # utilities
    dropbox
    incron
    ffmpeg
    calibre
    usbutils
    grsync

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

  home.shellAliases = {
    btw = "echo i use nixos, btw";
    nix-a = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
    nix-u = "nix flake update \n
             sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
    distro = "exec distrobox enter";
    charge-full = "sudo tlp fullcharge BAT0";
    charge-reset = "sudo tlp setcharge";
  };

  programs.bash = {
    enable = true;
		initExtra = ''
		  # echo git config on start
			[[ $- == *i* ]] && {
				echo "Git profile:"
				git config user.email
			}

		'';
	};

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    initContent = ''
      # echo git config on start
      [[ $- == *i* ]] && {
        echo "Git profile:"
        git config user.email
      }
    '';
  };
}
