{
  description = "NixOS setup for apb forked from https://github.com/mitchellh/nixos-config";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Build a custom WSL installer
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # darwin deps
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: let
    system.configurationRevision = self.rev or self.dirtyRev or null;
  
    # relative paths need to be tracked in git to be discoverable
    mkSystem = import ./lib/mksystem.nix {
      inherit nixpkgs inputs;
    };
  in {
    # use with vmware fusion
    nixosConfigurations.vm-aarch64 = mkSystem "vm-aarch64" {
      system = "aarch64-linux";
      user   = "apb";
    };
    # use with parallels (untested)
    nixosConfigurations.vm-aarch64-prl = mkSystem "vm-aarch64-prl" rec {
      system = "aarch64-linux";
      user   = "apb";
    };
    # use with utm (not working currently)
    nixosConfigurations.vm-aarch64-utm = mkSystem "vm-aarch64-utm" rec {
      system = "aarch64-linux";
      user   = "apb";
    };
    # use with vmware fusion on intel based mac (untested)
    nixosConfigurations.vm-intel = mkSystem "vm-intel" rec {
      system = "x86_64-linux";
      user   = "apb";
    };
    # use with wsl on a windows machine (untested)
    nixosConfigurations.wsl = mkSystem "wsl" {
      system = "x86_64-linux";
      user   = "apb";
      wsl    = true;
    };
    # use nix-darwin
    darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
      system = "aarch64-darwin";
      user   = "apb";
      darwin = true;
    };
  };
}
