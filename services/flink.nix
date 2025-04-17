{ config, lib, pkgs, ... }:
{
  options = {
    services.flink = {
      enable = lib.mkEnableOption "Enable flink service";
      package = lib.mkPackageOption pkgs "flink_1_17" { };
      logDir = lib.mkOption {
        type = lib.types.str;
        default = "\${PWD}/.data/flink/logs";
      };
      taskManagerSlots = lib.mkOption {
        type = lib.types.int;
        default = 4;
      };
    };
  };
  config =
    let
      cfg = config.services.flink;
    in
    lib.mkIf cfg.enable {
      settings.processes.flink = {
        command = "${cfg.package}/opt/flink/bin/start-cluster.sh";
        is_daemon = true;
        shutdown.command = "${cfg.package}/opt/flink/bin/stop-cluster.sh";
        environment = [
          "FLINK_LOG_DIR=${cfg.logDir}"
        ];
      };
    };
}
