{ pkgs, rcAppend ? "" }:
{
  enable = true;
  shellAliases = {
    ll = "ls -la";
    update = "sudo nixos-rebuild switch";
  };
  oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
  };
  localVariables = { };
  initExtra = ''
    # initialize direnv hooks
    eval "$(direnv hook zsh)"
  '' + rcAppend;
  plugins = [
    {
      name = "powerlevel10k";
      file = "powerlevel10k.zsh-theme";
      src = pkgs.fetchFromGitHub {
        owner = "romkatv";
        repo = "powerlevel10k";
        rev = "a9f208c8fc509b9c591169dd9758c48ad4325f76";
        sha256 = "XJ7gWcAq+xFqCbC3bTBWGTZ0ouftANInJ0fc2uptbco=";
      };
    }
    {
      name = "powerlevel10k-config";
      src = ./p10k-config;
      file = "p10k.zsh";
    }
  ];
}
