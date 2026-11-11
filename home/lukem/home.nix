#home.nix
{ config, pkgs, inputs, lib, ... }:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  obsidianOpen = pkgs.writeShellApplication {
    name = "obsidian-open";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.python3
      pkgs-unstable.obsidian
    ];
    text = builtins.readFile ../../scripts/obsidian-open;
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

  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # continue.continue
      # Note: google-antigravity is installed directly via VS Code marketplace
      davidanson.vscode-markdownlint
      arcticicestudio.nord-visual-studio-code
      mkhl.direnv
    ];
    profiles.default.userSettings = {};
  };

  home.packages = with pkgs; [
    # browsers
    firefox
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser
    chromium

    # dev tools
    distrobox
    pkgs-unstable.antigravity-cli
    # pkgs-unstable.antigravity-ide
    pkgs-unstable.antigravity-hub
    
    # media
    spotify
    #librepods
    discord

    # office tools
    #libreoffice
    onlyoffice-desktopeditors
    pkgs-unstable.obsidian
    obsidianOpen
    
    # media tools
    davinci-resolve
    video-downloader
    yt-dlp
    yt-dlg
    vlc
    handbrake
    remmina

    # utilities
    dropbox
    #incron -- automated davinci script
    ffmpeg
    calibre
    usbutils
    grsync

    # other apps
    safeeyes
    moonlight-qt

    # kde apps
    kdePackages.kclock
    kdePackages.isoimagewriter
    kdePackages.kcalc
    # these apps are already included with plasma
    #kdePackages.dolphin
    #kdePackages.dolphin-plugins
    #kdePackages.baloo-widgets
    #kdePackages.kate
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


  # Make markdown automatically open in Obsidian
  xdg.desktopEntries."obsidian-markdown-open" = {
    name = "Open in Obsidian";
    genericName = "Markdown Viewer";
    exec = "${obsidianOpen}/bin/obsidian-open %F";
    icon = "obsidian";
    terminal = false;
    categories = [ "Utility" "TextEditor" ];
    mimeType = [ "text/markdown" "text/x-markdown" "application/x-md" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/markdown" = [ "obsidian-markdown-open.desktop" ];
      "text/x-markdown" = [ "obsidian-markdown-open.desktop" ];
      "application/x-md" = [ "obsidian-markdown-open.desktop" ];
    };
  };

  home.shellAliases = {
    btw = "echo i use nixos, btw";
    nix-a = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
    nix-u = "nix flake update --flake ~/nixos-dotfiles && sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
    distro = "exec distrobox enter";
    charge-full = "sudo tlp fullcharge BAT0";
    charge-reset = "sudo tlp setcharge";
  };

  programs.bash = {
    enable = true;
		initExtra = ''
		  # echo git config on start
			# [[ $- == *i* ]] && {
			# 	echo "Git profile:"
			# 	git config user.email
			# }

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
      # [[ $- == *i* ]] && {
      #   echo "Git profile:"
      #   git config user.email
      # }
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
