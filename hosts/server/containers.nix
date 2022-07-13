let
  config = import ./configs.nix;
in
{
  backend = "docker";
  containers = {
    dbadminer = {
      autoStart = true;
      image = "adminer";
      ports = [ "${config.dbadminer.port}:8080" ];
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };

    jupyter = {
      autoStart = true;
      image = "sineliu/jupyterlab-all-in-one:latest";
      ports = [ "${config.jupyter.port}:8080" ];
      volumes = [ "${config.jupyter.folder}:/data" ];
      environment = {
        LABUID = "1000";
        LABGID = "1000";
        LABPASSWD = config.jupyter.password;
        JUPYTER_TOKEN = config.jupyter.token;
      };
    };

    bitwarden = {
      autoStart = true;
      image = "vaultwarden/server:latest";
      ports = [ "${config.bitwarden.port}:80" ];
      volumes = [ "${config.bitwarden.folder}:/data/" ];
      environment = {
        DOMAIN = config.bitwarden.domain;
        DATABASE_URL = config.bitwarden.db;
      };
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };
}
