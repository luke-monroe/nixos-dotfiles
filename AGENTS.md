# NixOS Dotfiles Configuration Guidelines

This repository contains my NixOS and Home Manager configuration.

## System Profile

Before making any changes or suggestions, always consider this specific hardware and software environment instead of assuming generic Linux or NixOS defaults.

- **OS:** NixOS (managed via flakes and home-manager)
- **Desktop Environment:** KDE Plasma (Wayland)
- **System:** ThinkPad P15 Gen 1
  - **CPU:** Intel i7-10850H @ 2.70GHz
  - **Graphics:** Hybrid (Intel iGPU UHD 630 + NVIDIA Quadro RTX 3000, muxless Optimus/PRIME)

### Hardware Wiring Constraints (CRITICAL)
- **Internal display:** Wired to iGPU (standard Optimus).
- **External ports:** (HDMI, Thunderbolt, USB-C) are hardwired *directly* to the NVIDIA dGPU. No external output can ever go through the iGPU on this model.
- **Max Displays:** Up to 5 total displays (1 internal + 4 external via HDMI/USB-C/2x TB).

*Note: I back up this configuration with GitHub, so I may maintain different branches for different display setups.*

## AI Agent Directives

1. **Context First:** Always verify my current display environment and settings before suggesting changes. Do not assume my setup is identical to a standard configuration.
2. **Critical Evaluation:** Do not blindly follow my directions if I make a poor design or configuration choice. If there is a better, more idiomatic NixOS or Nix way to achieve my goal, let me know and explain the alternative.
3. **Flakes and Home Manager:** Assume all configurations use Nix Flakes and Home Manager. Provide code snippets compatible with this modern structure.

## Reference Materials

Use the following official documentation for best practices and up-to-date syntax:
- [NixOS Tutorials](https://nix.dev/tutorials/nixos/index.html)
- [NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki)
- Refer to local or online NixOS Manual files for specific configuration options.
