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
