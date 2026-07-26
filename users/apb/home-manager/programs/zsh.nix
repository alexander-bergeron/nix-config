{
  programs.zsh = {
    enable = true;

    initContent = ''
      
      setopt GLOB_COMPLETE

      function oc_oauth_refresh() {
              echo "================================================"
              
              echo "Refreshing Anthropic OAuth Token"
              echo "------------------------------------------------"
              echo "test" | claude -p > /dev/null

              # Parse out tokens from keychain
              access_tkn=$(security find-generic-password -s 'Claude Code-credentials' -w | jq .claudeAiOauth.accessToken)
              refresh_tkn=$(security find-generic-password -s 'Claude Code-credentials' -w | jq .claudeAiOauth.refreshToken)
              exp_time=$(security find-generic-password -s 'Claude Code-credentials' -w | jq .claudeAiOauth.expiresAt)

              echo "OAuth Refresh Complete"
              echo "------------------------------------------------"
              echo "Access Token: $access_tkn"
              echo "Refresh Token: $refresh_tkn"
              echo "Expires At: $exp_time"

              echo "Writting new auth.json for opencode"
              echo "------------------------------------------------"
              jq --argjson refresh_tkn $refresh_tkn \
                --argjson access_tkn $access_tkn \
                --argjson exp_time $exp_time \
                '.anthropic.refresh = $refresh_tkn | .anthropic.access = $access_tkn | .anthropic.expires = $exp_time' "$HOME/.local/share/opencode/auth.json" > "$HOME/.local/share/opencode/auth.json.tmp"
              mv "$HOME/.local/share/opencode/auth.json.tmp" "$HOME/.local/share/opencode/auth.json"

              echo "Complete Exiting."
              echo "================================================"
      }

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
      # example $ git input.mov 800
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
