# NixOS Dotfiles

This repository contains my personal NixOS configuration, managed as a Nix flake. It includes both the system configuration and Home Manager configuration for my user.

## Repository Layout

```text
.
├── flake.nix
├── hosts/
│   └── thinkpad/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── home/
│   └── lukem/
│       └── home.nix
├── config/
└── ...
```

### `flake.nix`

The repository root is a Nix flake that exposes one NixOS configuration:

* `nixosConfigurations.thinkpad`

This output combines:

* the system configuration in `hosts/thinkpad`
* the Home Manager configuration in `home/lukem/home.nix`

Home Manager is integrated into the NixOS configuration, so rebuilding the system also applies the user configuration.

## Usage

From the repository root:

### Show available flake outputs

```bash
nix flake show
```

### Build the system without activating it

```bash
sudo nixos-rebuild build --flake .#thinkpad
```

### Build and switch to the new configuration

```bash
sudo nixos-rebuild switch --flake .#thinkpad
```

This command updates both:

* the NixOS system
* the Home Manager configuration for `lukem`

There is no need to run `home-manager switch`.

## Setting Up on a New Machine

1. Install NixOS.
2. Clone this repository.

```bash
git clone <repository-url> ~/nixos-dotfiles
cd ~/nixos-dotfiles
```

3. Copy the generated hardware configuration into the host directory.

```bash
sudo cp /etc/nixos/hardware-configuration.nix hosts/thinkpad/
```

4. Review any machine-specific settings, such as:

* NVIDIA PRIME PCI bus IDs
* hostname
* timezone
* storage configuration

5. Build and activate the system.

```bash
sudo nixos-rebuild switch --flake .#thinkpad
```

After the rebuild, both the operating system and the Home Manager configuration will be applied.

## Repository Structure

### `hosts/thinkpad`

Contains the NixOS system configuration, including:

* bootloader
* networking
* services
* users
* hardware configuration
* desktop environment
* system packages

### `home/lukem`

Contains the Home Manager configuration, including:

* Hyprland configuration
* shell configuration
* Git configuration
* editor configuration
* user packages
* application configuration

## Useful Commands

Rebuild after making changes:

```bash
sudo nixos-rebuild switch --flake .#thinkpad
```

Upgrade all flake inputs and rebuild:

```bash
sudo nixos-rebuild switch --upgrade --flake .#thinkpad
```

Update `flake.lock`:

```bash
nix flake update
```

Inspect available outputs:

```bash
nix flake show
```
