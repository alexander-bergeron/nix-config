{ config, pkgs, modulesPath, ... }: {
  imports = [
    ./hardware/vm-aarch64-utm.nix
    ./vm-shared.nix
  ];

  # UTM (QEMU-based hypervisor) configuration for aarch64
  
  # Network interface configuration
  # Uncomment and adjust the interface name based on your UTM VM setup
  # networking.interfaces.enp0s10.useDHCP = true;

  # SPICE daemon for display and mouse integration with UTM
  # Uncomment if you need enhanced display/mouse support
  # services.spice-vdagentd.enable = true;

  # Software rendering fallback for aarch64 VMs
  # Uncomment if you experience graphics/rendering issues
  # environment.variables.LIBGL_ALWAYS_SOFTWARE = "1";

  # aarch64 specific settings
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;
}
