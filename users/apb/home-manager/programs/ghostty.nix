{ isWSL, isDarwin, isLinux, ... }:
{ lib, ... }:
let
  ghosttySettings = ''
    font-family = JetBrains Mono
    background-opacity = 0.75
    background-blur-radius = 15
    macos-non-native-fullscreen = visible-menu
    macos-option-as-alt = left
    mouse-hide-while-typing = true
  '';
in {
  programs.ghostty = {
    enable = isLinux;
    settings = {
      font-size = 15;
      font-family = "JetBrains Mono";
      background-opacity = 0.80;
      background-blur-radius = 20;
      mouse-hide-while-typing = true;
    };
  };

  # Darwin uses a different config path outside of XDG
  home.file."Library/Application Support/com.mitchellh.ghostty/config" =
    lib.mkIf isDarwin {
      text = "font-size = 12\n" + ghosttySettings;
    };

  # Linux config is handled by programs.ghostty above via xdg
}
