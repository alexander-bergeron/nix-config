{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware/vm-aarch64-vb.nix
    ./vm-shared.nix
  ];

  # VirtualBox Guest Configuration for aarch64
  # VirtualBox on Apple Silicon has limited support but works with guest additions

  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.draganddrop = true;

  # Video driver configuration for VirtualBox
  services.xserver.videoDrivers = [ "virtualbox" ];

  # aarch64 specific settings for VirtualBox VMs
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # Network interface configuration
  # Uncomment and adjust if needed for your VirtualBox VM setup
  # networking.interfaces.eth0.useDHCP = true;
}
