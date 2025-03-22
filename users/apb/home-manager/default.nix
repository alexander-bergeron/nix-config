{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

in {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  xdg.enable = true;

  # import sub modules
  imports = [
    # pass in platform for setting configuration
    (import ./programs/alacritty.nix { inherit isWSL isDarwin isLinux; })
    (import ./programs/ghostty.nix { inherit isWSL isDarwin isLinux; })
    ./programs/git.nix
    ./programs/neovim.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.packages = [
    # Installed everywhere
    pkgs.buf
    # pkgs.colima
    pkgs.dbeaver-bin
    pkgs.duckdb
    # pkgs.docker
    # pkgs.docker-compose
    pkgs.fabric-ai
    pkgs.go
    pkgs.go-migrate
    # pkgs.ghostty
    pkgs.grpcurl
    pkgs.keepassxc
    pkgs.nodejs_22
    pkgs.obsidian
    pkgs.ollama
    pkgs.podman
    pkgs.podman-compose
    pkgs.protobuf
    pkgs.python3
    pkgs.pyright
    pkgs.ripgrep
    pkgs.rustup
    pkgs.sqlc
    pkgs.tinygo
    pkgs.tree
    pkgs.vim
  ] ++ (lib.optionals isDarwin [
    # Darwin Only Programs
    pkgs.aerospace
    # pkgs.logseq
    pkgs.mkalias
    pkgs.utm
    # pkgs.unifi
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    # Linux but not wsl
    pkgs.firefox
  ]);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
