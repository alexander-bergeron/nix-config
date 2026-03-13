{
  home.file.".config/opencode/config.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://localhost:11434/v1";
        };
        models = {
          "gpt-oss:20b" = {
            name = "GPT-OSS 20B";
            reasoning = true;
            tools = true;
          };
          "gpt-oss:120b" = {
            name = "GPT-OSS 120B";
            reasoning = true;
            tools = true;
          };
          "llama3.2" = {
            name = "Llama 3.2";
          };
          "llama3.3" = {
            name = "Llama 3.3";
          };
          "deepseek-coder:33b" = {
            name = "Deepseek-Coder 33B";
            tools = true;
          };
          "deepseek-r1:32b" = {
            name = "Deepseek R1 32B";
            reasoning = true;
            tools = true;
          };
          "lfm2:latest" = {
            name = "lfm2";
            tools = true;
          };
          "qwen3-coder:30b" = {
            name = "Qwen3 Coder 30B";
            reasoning = true;
            tool_call = true;
          };
          "qwen3.5:35b" = {
            name = "Qwen3.5 35B";
            reasoning = true;
            tool_call = true;
          };
        };
      };
      "LM Studio" = {
        npm = "@ai-sdk/openai-compatible";
        options = {
          baseURL = "http://localhost:1234/v1";
        };
        models = {
          "qwen3-coder-30b" = {
            id = "qwen/qwen3-coder-30b";
            reasoning = true;
            tool_call = true;
          };
        };
      };
    };
  };
}

# {
#   programs.opencode = {
#     enable = true;
#     
#     settings = {
#       provider = {
#         ollama = {
#           npm = "@ai-sdk/openai-compatible";
#           name = "Ollama (local)";
#           options = {
#             baseURL = "http://localhost:11434/v1";
#           };
#           models = {
#             "oc-qwen:latest" = {
#               name = "Qwen3 Coder 30B";
#               reasoning = true;
#               tools = true;
#             };
#           };
#         };
#         "LM Studio" = {
#           npm = "@ai-sdk/openai-compatible";
#           options = {
#             baseURL = "http://localhost:1234/v1";
#           };
#           models = {
#             "qwen3-coder-30b" = {
#               id = "qwen/qwen3-coder-30b";
#               reasoning = true;
#               tool_call = true;
#             };
#           };
#         };
#       };
#     };
#   };
# }
