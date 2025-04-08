{
  programs.zsh = {
    enable = true;

    initExtra = ''
      # better tree clippy
      function cp_tree() {
        (
          tree
          find . -type f | sort | while read -r file; do
            echo -e "\nFile: $file"
            cat "$file"
          done
        ) | pbcopy
      }

      # .mov to .gif - https://gist.github.com/imseeeb/6890df0ff1683f1fff961ce14b0a21b2
      gif() { ffmpeg -i $1 -pix_fmt rgb8 -r 10 -vf "scale=$2:-2" output.gif && gifsicle --optimize=3 output.gif -o output.gif }
    '';

    autocd = true;
    autosuggestion = {
      enable = true;
    };

    enableCompletion = true;

    history = {
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      save = 1000000;
      size = 1000000;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
    };
  };
}
