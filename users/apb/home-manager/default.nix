{ isWSL, inputs, ... }:

{ config, lib, pkgs, pkgs-unstable, ... }:

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
    ./programs/opencode.nix
    ./programs/starship.nix
    ./programs/tmux.nix
    ./programs/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.packages = [
    # Installed everywhere
    pkgs.aider-chat
    pkgs.buf
    pkgs.bun
    pkgs-unstable.colima
    pkgs.dbeaver-bin
    pkgs.duckdb
    pkgs.docker
    pkgs.docker-compose
    pkgs.dotnetCorePackages.sdk_8_0-bin
    pkgs.fabric-ai
    pkgs.ffmpeg
    pkgs.gifsicle
    pkgs.go
    # pkgs.go-migrate
    # pkgs.go-migrate-pg
    pkgs.ghostty-bin
    pkgs.grpcurl
    pkgs.keepassxc
    pkgs.kompose
    pkgs.kubectl
    # pkgs.libreoffice-bin
    # pkgs-unstable.lmstudio
    pkgs.lua
    pkgs.minikube
    pkgs.nodejs_22
    pkgs.obsidian
    pkgs-unstable.ollama
    pkgs-unstable.opencode
    # pkgs.ollama
    # pkgs.opencode
    pkgs.pgadmin4
    pkgs.podman
    pkgs.podman-compose
    pkgs.protobuf
    pkgs.python3
    pkgs.pyright
    pkgs.ripgrep
    pkgs.rustup
    pkgs.sqlc
    # pkgs.tinygo
    pkgs.tree
    pkgs.uv
    pkgs.vim
    pkgs.yt-dlp
    pkgs.wireshark
    # pkgs.zed-editor
    # pkgs-unstable.zed-editor
  ] ++ (lib.optionals isDarwin [
    # Darwin Only Programs
    pkgs.aerospace
    pkgs.go-migrate-pg
    pkgs.libreoffice-bin
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
