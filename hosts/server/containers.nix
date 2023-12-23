let
  config = import ./configs.nix;
in
{
  backend = "docker";
  containers = if config.maintenance then {} else {
    dbadminer = {
      autoStart = true;
      image = "adminer";
      ports = [ "${config.dbadminer.port}:8080" ];
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };

    jupyter = {
      autoStart = true;
      image = "sineliu/jupyterlab-all-in-one:latest";
      ports = [ "${config.jupyter.code-port}:8080" "${config.jupyter.lab-port}:8081" ];
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
      image = "lscr.io/linuxserver/nextcloud:25.0.2";
      # forcing ipv4 as ipv6 breaks nextcloud, see https://github.com/nextcloud/android/issues/7400.
      ports = [ "0.0.0.0:${config.nextcloud.port}:80" ];
      volumes = [ "${config.nextcloud.datafolder}:/data" "${config.nextcloud.configfolder}:/config" ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = "Asia/Shanghai";
      };
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };

    nocodb = {
      autoStart = true;
      image = "nocodb/nocodb:0.100.2";
      ports = [ "${config.nocodb.port}:8080" ];
      volumes = [ "${config.nocodb.folder}:/data" ];
      environment = {
        NC_DB = config.nocodb.db;
        NC_AUTH_JWT_SECRET = config.nocodb.jwt;
        NC_JWT_EXPIRES_IN = "10000h";
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

    kiwi = {
      autoStart = true;
      image = "sineliu/kiwi:0.10.1";
      ports = [ "${config.kiwi.port}:8080" ];
      volumes = [ "${config.kiwi.folder}:/data" "${config.kiwi.log-folder}:/logs" ];
      user = "1000:100";
    };

    rsshub = {
      autoStart = true;
      image = "diygod/rsshub:2023-09-29";
      ports = [ "${config.rsshub.port}:1200" ];
      environment = {
        REQUEST_RETRY = "5";
        REQUEST_TIMEOUT = "10000";
        ALLOW_ORIGIN = "*";
      } // config.rsshub.environment;
    };

    freshrss = {
      autoStart = true;
      image = "freshrss/freshrss:1.21.0";
      ports = [ "${config.freshrss.port}:80" ];
      volumes = [ "${config.freshrss.folder}/data:/var/www/FreshRSS/data" "${config.freshrss.folder}/extensions:/var/www/FreshRSS/extensions" ];
      environment = {
        TZ = "Asia/Shanghai";
        CRON_MIN = "13,43";
      };
    };

    n8n = {
      autoStart = true;
      image = "docker.n8n.io/n8nio/n8n:1.9.0";
      ports = [ "${config.n8n.port}:5678" ];
      volumes = [ "${config.n8n.folder}:/home/node/.n8n" ];
      environment = {
        GENERIC_TIMEZONE = "Asia/Shanghai";
        TZ = "Asia/Shanghai";
        DB_TYPE="postgresdb";
        DB_POSTGRESDB_HOST=config.host;
        DB_POSTGRESDB_PORT=toString config.postgres.port;
        DB_POSTGRESDB_DATABASE=config.n8n.dbname;
        DB_POSTGRESDB_USER=config.n8n.dbuser;
        DB_POSTGRESDB_PASSWORD=config.n8n.dbpass;
      } // config.n8n.environment;
    };
  };
}
