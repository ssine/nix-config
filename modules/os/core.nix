{ config, pkgs, ... }:
let
  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in
{
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    chromium
    neofetch
    python-with-my-packages
    htop
    tmux
    element-desktop
    arc-kde-theme
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
