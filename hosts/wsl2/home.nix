{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  home.enableNixpkgsReleaseCheck = true;

  programs.git = {
    enable = true;
    userName = "sine";
    userEmail = "liu.siyao@qq.com";
    lfs.enable = true;
    extraConfig = {
      # replace crlf with lf. https://stackoverflow.com/questions/1967370/git-replacing-lf-with-crlf
      core = { autocrlf = "input"; };
      pull.rebase = false;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
    nix-direnv.enableFlakes = true;
  };

  programs.zsh = (import ../../modules/home-manager/zsh) {
    inherit pkgs;
    rcAppend = ''
      # proxy to ssr host in windows
      export host_ip=$(cat /etc/resolv.conf |grep "nameserver" |cut -f 2 -d " ")
      toggle_proxy () {
        if [[ -z "''${http_proxy}" ]]; then
          export all_proxy=http://$host_ip:8889 http_proxy=http://$host_ip:8889 https_proxy=http://$host_ip:8889
          echo "proxy on"
        else
          unset all_proxy http_proxy https_proxy
          echo "proxy off"
        fi
      }
      alias proxy=toggle_proxy
    '';
  };

  imports = [
    # ../../modules/home-manager/zsh
  ];

  home.packages = (import ../../modules/common).devtools pkgs ++ (with pkgs; [
    kubectl
    ncat
    # if any font warning occurs: `sudo apt install fontconfig`
    plantuml
    graphviz
  ]);

  home.sessionVariables = {
    NO_UPDATE_NOTIFIER = 1; # disable npm update notification
  };
}
