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

Flake.nix is the entry point for building the nix configuration. It brings together the system configuration in `hosts/thinkpad` and the Home Manager configuration in `home/lukem/home.nix`

## Usage

From the repository root:

### Build the system without activating it

```bash
sudo nixos-rebuild build --flake .#thinkpad
```

### Build and switch to the new configuration

```bash
sudo nixos-rebuild switch --flake .#thinkpad
```
### Update flake

App versions are pinned in `flake.lock` so you must specifically update it with:

```bash
nix flake update
```

### Useful aliases

I have set up some aliases in home.nix so instead of running the above commands you can just run nix-u to build and switch to the configuration or nix-a to update the flake, build, and switch to the configuration. 


## Setting Up on a New Machine

1. Install NixOS.
2. Clone this repository into your home directory.
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

* desktop environment / display manager configuration
* shell configuration
* Git configuration
* editor configuration
* user packages
* application configuration
