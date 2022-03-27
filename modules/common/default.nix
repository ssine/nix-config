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
    telnet

    # monitor
    htop
    iotop
    atop
    neofetch

    # shell
    tmux

    # common languages
    # go_1_16
    go_1_15
    gnumake
    nodejs-16_x
    nodePackages.typescript
    (python38.withPackages (p: with p; [
      requests
      pandas
    ]))
    poetry
    nixpkgs-fmt
    jdk17
  ];
}
