{
  devtools = pkgs: with pkgs; [
    # file manipulation
    vim
    zip
    unzip
    less

    # network
    wget
    openssh
    unixtools.netstat
    inetutils

    # monitor
    htop
    iotop
    atop
    neofetch

    # shell
    tmux

    # common languages & dev tools
    cloc
    ffmpeg
    python310Packages.gprof2dot

    # golang, see https://mgdm.net/weblog/vscode-nix-go-tools/
    go
    gotools
    gopls
    go-outline
    gocode
    gopkgs
    gocode-gomod
    godef
    golint

    gcc
    gnumake

    nodejs-16_x
    yarn
    nodePackages.typescript

    (python3.withPackages (p: with p; [
      requests
      pandas
      yapf
      ipykernel
    ]))
    poetry

    nixpkgs-fmt

    jdk17
  ];

  servertools = pkgs: with pkgs; [
    # file manipulation
    vim
    zip
    unzip
    less

    # network
    wget
    openssh
    unixtools.netstat
    inetutils

    # monitor
    htop
    iotop
    atop
    neofetch

    # shell
    tmux

    # common languages & dev tools
    git
    cloc

    nodejs-16_x
    yarn
    nodePackages.typescript
  ];
}
