#home.nix
{ config, pkgs, inputs, lib, ... }:

let
  privateGitIdentityPath = ./git-identity-private.nix;
  privateGitIdentity =
    if builtins.pathExists privateGitIdentityPath
    then import privateGitIdentityPath
    else {
      defaultName = "Your Name";
      schoolName = "your-school-username";
      defaultEmail = "your-email@example.com";
      schoolEmail = "your-school-email@example.edu";
    };
in
{
  home.username = "lukem";
  home.homeDirectory = "/home/lukem";
  home.stateVersion = "25.05";


	programs.git = {
		enable = true;
		includes = [
		  {
		    condition = "gitdir:~/Projects/School/";
		    contents = {
          settings.user.name = privateGitIdentity.schoolName;
          settings.user.email = privateGitIdentity.schoolEmail;
		    };
		  }
		];
		settings = {
				init.defaultBranch = "main";
        user.name = privateGitIdentity.defaultName;
        user.email = privateGitIdentity.defaultEmail;
		};
	};
	programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      continue.continue
    ];
  };
  home.packages = with pkgs; [
    mission-center

    firefox
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser
    chromium

		nodejs
    tailscale
    ollama

    spotify
    davinci-resolve
    kdePackages.kate
    libreoffice
    kdePackages.kdeconnect-kde

    
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      nix-a = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#thinkpad";
      nix-u = "sudo nixos-rebuild switch --upgrade --flake ~/nixos-dotfiles#thinkpad";
    };
		initExtra = ''
		  # echo git config on start
			[[ $- == *i* ]] && {
				echo "Git profile:"
				git config --global user.email
			}

		'';
	};
}