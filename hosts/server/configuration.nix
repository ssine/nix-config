{ home-manager, ... }@inputs:
{ config, pkgs, modulesPath, ... }:
let
  configs = import ./configs.nix;
in
{
  # nixops machine property
  deployment = {
    targetHost = configs.host;
    name = "homeserver";
    uuid = "6edf29a9-f665-401a-9786-7fa3eca9986a";
    provisionSSHKey = false;
  };

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager
    ];

  virtualisation = {
    docker.enable = true;
    oci-containers = import ./containers.nix;
  };

  systemd.services.fava = {
    enable = true;
    description = "fava";
    serviceConfig = {
      WorkingDirectory = inputs.neon.legacyPackages.x86_64-linux.neon;
      ExecStart = "${pkgs.nix}/bin/nix develop -c make start-fava";
      User = "sine";
    };
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.git
    ];
  };

  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "homeserver"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.utf8";
    LC_IDENTIFICATION = "zh_CN.utf8";
    LC_MEASUREMENT = "zh_CN.utf8";
    LC_MONETARY = "zh_CN.utf8";
    LC_NAME = "zh_CN.utf8";
    LC_NUMERIC = "zh_CN.utf8";
    LC_PAPER = "zh_CN.utf8";
    LC_TELEPHONE = "zh_CN.utf8";
    LC_TIME = "zh_CN.utf8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sine = {
    isNormalUser = true;
    description = "Siyao Liu";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  home-manager = {
    users.sine = {
      home.stateVersion = "22.05";
      programs.zsh = (import ../../modules/home-manager/zsh) {
        inherit pkgs;
      };
      programs.home-manager.enable = true;
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
      home.file."secret-folder/neon".source = inputs.neon.legacyPackages.x86_64-linux.neon;
      home.packages = [ ];
    };
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "sine";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (import ../../modules/common).servertools pkgs ++ (with pkgs; [
    ossutil
    postgresql_14
  ]);

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}