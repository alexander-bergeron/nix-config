# VirtualBox aarch64 hardware configuration
# Generated from nixos-generate-config with typical VirtualBox VM settings
# Kernel modules are based on standard SATA/AHCI VirtualBox setup

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # VirtualBox typically uses AHCI for storage
  boot.initrd.availableKernelModules = [ "ata_piix" "ahci" "xhci_pci" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];
}
