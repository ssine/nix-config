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

    nextcloud = {
      autoStart = true;
      image = "lscr.io/linuxserver/nextcloud:24.0.2";
      ports = [ "${config.nextcloud.port}:80" ];
      volumes = [ "${config.nextcloud.datafolder}:/data" "${config.nextcloud.configfolder}:/config" ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Asia/Shanghai";
      };
    };

    nocodb = {
      autoStart = true;
      image = "nocodb/nocodb:0.92.0";
      ports = [ "${config.nocodb.port}:8080" ];
      volumes = [ "${config.nocodb.folder}:/data" ];
      environment = {
        NC_DB = config.nocodb.db;
        NC_AUTH_JWT_SECRET = config.nocodb.jwt;
        DB_QUERY_LIMIT_MIN = "1";
        DB_QUERY_LIMIT_DEFAULT = "100";
        DB_QUERY_LIMIT_MAX = "100";
      };
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };

    metabase = {
      autoStart = true;
      image = "metabase/metabase:v0.43.1";
      ports = [ "${config.metabase.port}:3000" ];
      environment = {
        MB_DB_TYPE = "postgres";
        MB_DB_HOST = config.dockerhost;
        MB_DB_PORT = toString config.postgres.port;
        MB_DB_DBNAME = config.metabase.dbname;
        MB_DB_USER = config.postgres.user;
        MB_DB_PASS = config.postgres.password;
      };
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };
}
