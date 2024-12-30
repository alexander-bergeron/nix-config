{ isWSL, isDarwin, isLinux, ... }:

{
  programs.alacritty = {
    enable = !isWSL;

    settings = {
      font.size = (if isDarwin then 11.0 else 13.0);
      font.normal = {
        family = "JetBrainsMono Nerd Font";
        style = "Regular";
      };
    };
  };
}
