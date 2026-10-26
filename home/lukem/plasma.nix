{ config, lib, pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    # ── Workspace & Theme ───────────────────────────────────────────────
    workspace = {
      # Light mode with dark taskbar
      theme = "breeze-dark";
      colorScheme = "BreezeLight";
    };

    # ── Input Devices ───────────────────────────────────────────────────
    input.keyboard.numlockOnStartup = "on";

    # ── Shortcuts & Keybindings ─────────────────────────────────────────
    shortcuts = {
      # KWin window management
      kwin = {
        "Walk Through Windows" = "Alt+Tab";
        "Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
        "Overview" = [ "Meta+Tab" ];
        "MinimizeAll" = "Meta+`";
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
      kwinrulesrc."391f588d-7088-4d68-90ad-b89bcd6aa4c8".Description = "Window settings for zen";
      kwinrulesrc."391f588d-7088-4d68-90ad-b89bcd6aa4c8".desktops = "\\0";
      kwinrulesrc."391f588d-7088-4d68-90ad-b89bcd6aa4c8".desktopsrule = 2;
      kwinrulesrc."391f588d-7088-4d68-90ad-b89bcd6aa4c8".types = 1;
      kwinrulesrc."391f588d-7088-4d68-90ad-b89bcd6aa4c8".wmclass = "zen";
      kwinrulesrc."391f588d-7088-4d68-90ad-b89bcd6aa4c8".wmclassmatch = 1;
    };
  };
}
