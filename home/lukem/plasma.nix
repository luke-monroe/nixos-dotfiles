{ config, lib, pkgs, ... }:

{
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    # ── Shortcuts & Keybindings ─────────────────────────────────────────
    shortcuts = {
      # KWin window management
      kwin = {
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
        "Overview" = [ "Meta+Tab" ];

        # Mouse Tiler script bindings
      };

      # Media Playback
      mediacontrol = {
        "nextmedia" = [ "Media Next" "Meta+N" ];
        "pausemedia" = "Media Pause";
        "playpausemedia" = [ "Media Play" "Meta+Space" ];
        "previousmedia" = [ "Media Previous" "Meta+B" ];
        "seekforwardmedia" = "Media Fast Forward";
        "seekbackwardmedia" = "Media Rewind";
        "stopmedia" = "Media Stop";
      };

      # Volume & Audio
      kmix = {
        "increase_volume" = "Volume Up";
        "decrease_volume" = "Volume Down";
        "increase_volume_small" = "Shift+Volume Up";
        "decrease_volume_small" = "Shift+Volume Down";
        "mute" = "Volume Mute";
        "mic_mute" = [ "Microphone Mute" "Meta+Volume Mute" ];
        "increase_microphone_volume" = "Microphone Volume Up";
        "decrease_microphone_volume" = "Microphone Volume Down";
      };

    };

    # ── Custom Config Files (rc / ini) ──────────────────────────────────
    configFile = {
      # Keyboard: Swap Caps Lock and Escape
      "kxkbrc"."Layout"."Options" = "caps:swapescape";
      "kxkbrc"."Layout"."ResetOldOptions" = true;

      # Mouse & Touchpad settings
      "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad" = {
        "NaturalScroll" = true;
        "PointerAcceleration" = 0.460;
        "ScrollFactor" = 0.5;
      };
      "kcminputrc"."Libinput/1133/16493/Logitech M705" = {
        "PointerAcceleration" = "-0.100";
        "PointerAccelerationProfile" = 2;
        "ScrollFactor" = 0.5;
      };


      # Window Behavior & Focus
      "kwinrc"."Windows" = {
        "FocusPolicy" = "FocusFollowsMouse";
      };

      # Window Decorations & Titlebar buttons
      "kwinrc"."org.kde.kdecoration2" = {
        "BorderSize" = "None";
        "BorderSizeAuto" = false;
        "ButtonsOnLeft" = "SFB";
        "ButtonsOnRight" = "IAX";
        "theme" = "Breeze";
      };

      # KWin Effects (Wobbly windows, Blur, Night Color)
      "kwinrc"."NightColor"."Active" = true;
      "kwinrc"."Plugins" = {
        "blurEnabled" = true;
        "wobblywindowsEnabled" = true;
        "minimizeallEnabled" = true;
        "mousetilerEnabled" = true;
      };
      "kwinrc"."Effect-blur"."BlurStrength" = 10;
      "kwinrc"."Effect-wobblywindows" = {
        "AdvancedMode" = true;
        "Drag" = 69;
        "MoveFactor" = 22;
        "ResizeWobble" = false;
        "Stiffness" = 13;
      };

      # Window Rules
      "kwinrulesrc"."eb4780c6-017b-4905-b87e-fffc931bfff8" = {
        "Description" = "Dark Bar for Spotify";
        "decocolor" = "BreezeDark";
        "decocolorrule" = 2;
        "wmclass" = "spotify";
        "wmclasscomplete" = true;
        "wmclassmatch" = 2;
      };
      "kwinrulesrc"."eb088a0e-d50e-4dcd-93d8-1d36e1255e0e" = {
        "Description" = "Zen Browser on all Desktops";
        "activity" = "00000000-0000-0000-0000-000000000000";
        "activityrule" = 3;
        "desktops" = "\\0";
        "desktopsrule" = 3;
        "wmclass" = "zen";
        "wmclassmatch" = 1;
      };
    };
  };
}
