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
    onlyoffice-desktopeditors

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
}
