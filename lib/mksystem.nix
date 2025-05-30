# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, inputs }:

name:
{
  system,
  user,
  darwin ? false,
  wsl ? false
}:

let
  # True if this is a WSL system.
  isWSL = wsl;

  # The config files for this system.
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if darwin then "darwin" else "nixos" }.nix;
  userHMConfig = ../users/${user}/home-manager;

  # NixOS vs nix-darwin functionst
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager = if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;
in systemFunc rec {
  inherit system;

  modules = [
    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

    machineConfig
    userOSConfig
    home-manager.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        isWSL = isWSL;
        inputs = inputs;
      };
    }

    # Conditionally bring in Homebrew if on Darwin
    (if darwin then
      {
        # Import the nix-homebrew module
        imports = [
          inputs.nix-homebrew.darwinModules.nix-homebrew
        ];

        # Configure nix-homebrew options
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "${user}";
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
          };
          mutableTaps = true; # TODO: temporary, should be false - permission error
        };
      }
    else {})

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        isWSL = isWSL;
        inputs = inputs;
      };
    }
  ];

}
