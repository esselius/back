{ config, lib, pkgs, ... }:
{
  options = {
    services.zeppelin = {
      enable = lib.mkEnableOption "Enable hello service";
      package = lib.mkPackageOption pkgs "zeppelin" { };
      logDir = lib.mkOption {
        type = lib.types.str;
        default = ".data/zeppelin/logs";
      };
      pidDir = lib.mkOption {
        type = lib.types.str;
        default = ".data/zeppelin/run";
      };
      notebookDir = lib.mkOption {
        type = lib.types.str;
        default = "$${PWD}";
      };
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "$${PWD}/.data/zeppeling/conf";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8089;
      };
    };
  };
  config =
    let
      cfg = config.services.zeppelin;
    in
    lib.mkIf cfg.enable {
      settings.processes.zeppelin = {
        command = "${cfg.package}/bin/zeppelin.sh";
        environment = [
          "ZEPPELIN_LOG_DIR=${cfg.logDir}"
          "ZEPPELIN_PID_DIR=${cfg.pidDir}"
          "ZEPPELIN_NOTEBOOK_DIR=$${PWD}"
          "ZEPPELIN_CONFIG_FS_DIR=$${PWD}/.data/zeppelin/conf"
          "ZEPPELIN_WAR_TEMPDIR=$${PWD}/.data/zeppelin/tmp"
          "ZEPPELIN_PORT=${toString cfg.port}"
          "USE_HADOOP=false"
        ];
      };
    };
}
