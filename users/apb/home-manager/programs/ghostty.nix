{ isWSL, isDarwin, isLinux, ... }:

{
  programs.ghostty = {
    enable = isLinux;

    settings = {
      font-size = (if isDarwin then 11 else 15);
      font-family = "JetBrains Mono";
      background-opacity = 0.80;
      background-blur-radius = 20;
      macos-non-native-fullscreen = "visible-menu";
      macos-option-as-alt = "left";
      mouse-hide-while-typing = true;
    };
  };
}
