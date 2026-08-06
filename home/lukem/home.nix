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

  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        
      };
      version = 2;
    };
    settings = {};
  };

	home.file.".config/hypr/hyprland.conf".source = ../../config/hyprland.conf;

  # ── Screen lock & idle ────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [{
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 7;
      }];
      input-field = [{
        monitor = "";
        size = "300, 50";
        outline_thickness = 2;
        placeholder_text = "";
        fail_text = "";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "hyprlock";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # ── Polkit agent as a reliable systemd service ────────────────────────
  systemd.user.services.polkit-gnome-agent = {
    Unit = {
      Description = "GNOME Polkit authentication agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

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
    mousepad
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