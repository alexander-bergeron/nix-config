{ config, pkgs, ... }: {
  # Set in Sept 2024 as part of the macOS Sequoia release.
  system.stateVersion = 5;

  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  # nix.useDaemon = true;
  ids.gids.nixbld = 350;

  # Keep in async with vm-shared.nix. (todo: pull this out into a file)
  nix = {
    # We need to enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # public binary cache that I use for all my derivations. You can keep
    # this, use your own, or toss it. Its typically safe to use a binary cache
    # since the data inside is checksummed.
    # settings = {
    #   substituters = ["https://mitchellh-nixos-config.cachix.org"];
    #   trusted-public-keys = ["mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="];
    # };
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
    '';

  environment.shells = with pkgs; [ bashInteractive zsh ];
  environment.systemPackages = with pkgs; [
    # cachix
    mkalias
  ];

  # Activation script to instal rosetta. Required for homebrew.
  system.activationScripts.extraActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license
  '';

  # Activation script to create aliases for spotlight.
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
    '';

  # sleep settings
  power.sleep.display = 10;
  power.sleep.computer = 10;

  # Turn off startup chime
  system.startup.chime = false;

  # Set Apple system settings.
  system.defaults = {
    alf.globalstate = 1; # Enable Firewall
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.GuestEnabled = false;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain."com.apple.keyboard.fnState" = true;
    # dock.persistent-apps = [
    #   "/System/Applications/Launchpad.app"
    #   "/Applications/Firefox.app"
    #   "${pkgs.obsidian}/Applications/Obsidian.app"
    #   "/Applications/ProtonVPN.app"
    #   "/Applications/VMware Fusion.app"
    #   "${pkgs.keepassxc}/Applications/KeePassXC.app"
    #   "${pkgs.alacritty}/Applications/Alacritty.app"
    #   "/System/Applications/System Settings.app"
    # ];
    dock.show-recents = false;
    dock.tilesize = 32;
    dock.orientation = "right";
    WindowManager.EnableStandardClickToShowDesktop = false;
  };

  # Install nerdfont for alacritty.
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

}
