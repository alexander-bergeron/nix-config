{ inputs, pkgs, ... }:

{
  # environment.systemPackages = [
  #   pkgs.alacritty
  #   pkgs.colima
  #   pkgs.dbeaver-bin
  #   pkgs.docker
  #   pkgs.docker-compose
  #   pkgs.keepassxc
  #   pkgs.mkalias
  #   pkgs.neovim
  #   pkgs.obsidian
  #   pkgs.vim
  # ];

  homebrew = {
    enable = true;

    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
    ];

    casks = [
      # "chromedriver"
      "displaylink"
      "firefox"
      # "ghostty"
      {
        name = "ghostty";
        greedy = true;
      }
      # "google-chrome"
      "logi-options+"
      "protonvpn"
      # "raspberry-pi-imager"
      # "ubiquiti-unifi-controller"
      "vmware-fusion"
    ];

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    global = {
      brewfile = true;
    };
  };

  # Set Apple system settings.
  system.defaults = {
    # alf.globalstate = 1; # Enable Firewall
    # finder.FXPreferredViewStyle = "clmv";
    # loginwindow.GuestEnabled = false;
    # NSGlobalDomain.KeyRepeat = 2;
    # NSGlobalDomain.InitialKeyRepeat = 15;
    # NSGlobalDomain.AppleInterfaceStyle = "Dark";
    # NSGlobalDomain."com.apple.keyboard.fnState" = true;
    dock.persistent-apps = [
      "/System/Applications/Launchpad.app"
      "/Applications/Firefox.app"
      "${pkgs.obsidian}/Applications/Obsidian.app"
      "/Applications/ProtonVPN.app"
      "/Applications/VMware Fusion.app"
      "${pkgs.keepassxc}/Applications/KeePassXC.app"
      # "${pkgs.alacritty}/Applications/Alacritty.app"
      "/Applications/Ghostty.app"
      "/System/Applications/System Settings.app"
    ];
    # dock.show-recents = false;
    # dock.tilesize = 32;
    # dock.orientation = "right";
    # WindowManager.EnableStandardClickToShowDesktop = false;
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.apb = {
    home = "/Users/apb";
    shell = pkgs.zsh;
  };
}
