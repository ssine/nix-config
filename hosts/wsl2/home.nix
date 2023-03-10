inputs:
{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "python3.10-poetry-1.2.2"
    "python3.10-certifi-2022.9.24"
  ];
  nixpkgs.overlays = [
    inputs.android-nixpkgs.overlay
  ];
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

  programs.nix-index = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

      # >>> conda initialize >>>
      # !! Contents within this block are managed by 'conda init' !!
      __conda_setup="$('/home/sine/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "/home/sine/opt/miniconda3/etc/profile.d/conda.sh" ]; then
              . "/home/sine/opt/miniconda3/etc/profile.d/conda.sh"
          else
              export PATH="/home/sine/opt/miniconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup
      # <<< conda initialize <<<

      export PATH="/home/sine/.nix-profile/bin:$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin/:/mnt/c/Program Files/Microsoft VS Code/bin"
    '';
  };

  imports = [
    ../../modules/home-manager/conda
    inputs.android-nixpkgs.hmModule
  ];

  # android-sdk = {
  #   enable = true;
  #   packages = sdk: with sdk; [
  #     build-tools-32-0-0
  #     cmdline-tools-latest
  #     emulator
  #     platforms-android-32
  #     sources-android-32
  #   ];
  # };

  home.packages = (import ../../modules/common).devtools pkgs ++ (with pkgs; [
    kubectl
    nmap
    # if any font warning occurs: `sudo apt install fontconfig`
    plantuml
    graphviz

    minikube
    kubernetes-helm
    mongodb
    terraform
    # awscli
    # google-cloud-sdk
    (google-cloud-sdk.withExtraComponents ([google-cloud-sdk.components.gke-gcloud-auth-plugin]))

    nodePackages.madoko
    texlive.combined.scheme-full

    hugo

    # inputs.rnix-lsp.defaultPackage."x86_64-linux"

    nixops_unstable

    cargo
    rustc
    rustfmt
    pkg-config
    rust-analyzer
    cargo-watch

    nixfmt
    nil

    # used to forward usb devices from windows to wsl
    # linuxKernel.packages.linux_5_15.usbip
  ]);

  home.sessionVariables = {
    NO_UPDATE_NOTIFIER = 1; # disable npm update notification
    DIRENV_LOG_FORMAT = ""; # FIXME: disable direnv output, seems not working
  };
}
