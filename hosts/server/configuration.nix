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
    docker.liveRestore = false;
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

  systemd.services.caddy = {
    enable = true;
    description = "caddy";
    serviceConfig = {
      ExecStart = "${pkgs.caddy}/bin/caddy run --environ --adapter caddyfile --config " + pkgs.writeText "Caddyfile" configs.caddy.caddy-file;
      User = "sine";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    port = configs.postgres.port;
    enableTCPIP = true;
    authentication = ''
      host all all all password
    '';
    ensureDatabases = [ "main" configs.bitwarden.dbname configs.nocodb.dbname configs.metabase.dbname ];
    ensureUsers = [
      {
        name = "sine";
        ensurePermissions = {
          "DATABASE main" = "ALL PRIVILEGES";
          "DATABASE ${configs.nocodb.dbname}" = "ALL PRIVILEGES";
          "DATABASE ${configs.metabase.dbname}" = "ALL PRIVILEGES";
        };
      }
      {
        name = configs.bitwarden.dbuser;
        ensurePermissions = {
          "DATABASE ${configs.bitwarden.dbname}" = "ALL PRIVILEGES";
        };
      }
    ];
    initialScript = pkgs.writeText "pg-init.sql" ''
      CREATE ROLE "${configs.postgres.user}" WITH LOGIN PASSWORD '${configs.postgres.password}';
      CREATE ROLE "${configs.bitwarden.dbuser}" WITH LOGIN PASSWORD '${configs.bitwarden.dbpass}';
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };


  systemd.services.sync-wiki = {
    enable = true;
    description = "sync-wiki";
    startAt = "daily";
    serviceConfig = {
      WorkingDirectory = configs.kiwi.folder;
      ExecStart = ''${pkgs.bash}/bin/bash -c "git add . && (git commit -m 'daily update' || true) && git push"'';
      User = "sine";
    };
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.git
      pkgs.openssh
    ];
  };

  services.matrix-synapse = {
    enable = true;
    dataDir = configs.synapse.folder;
    settings = {
      server_name = configs.synapse.domain;
      enable_registration = true;
      enable_registration_without_verification = true;
      suppress_key_server_warning = true;
      registration_shared_secret = configs.synapse.registration-shared-secret;
      signing_key_path = pkgs.writeText "synapse.signing.key" configs.synapse.signing-key;
      log_config = pkgs.writeText "synapse.log.config" configs.synapse.log-config;
      listeners = [{
        port = configs.synapse.port;
        tls = false;
        type = "http";
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = true;
        }];
      }];
      database = {
        name = "psycopg2";
        args = {
          port = configs.postgres.port;
          database = "matrix-synapse";
          user = "matrix-synapse";
        };
      };
    };
  };
  systemd.services.matrix-synapse.serviceConfig.ExecStartPre = [ "" ]; # fix chmod on /nix/store error

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
