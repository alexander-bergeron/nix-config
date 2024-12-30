{ pkgs, inputs, ... }:

{
  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  programs.zsh.enable = true;

  users.users.apb = {
    isNormalUser = true;
    home = "/home/apb";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "root";
  };
}
