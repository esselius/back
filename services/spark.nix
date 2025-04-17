{ config, lib, pkgs, ... }:
{
  options = {
    services.spark = {
      enable = lib.mkEnableOption "Enable spark service";
      package = lib.mkPackageOption pkgs "spark_3_5" { };
      logDir = lib.mkOption {
        type = lib.types.str;
        default = "\${PWD}/.data/spark/logs";
      };
      # taskManagerSlots = lib.mkOption {
      #   type = lib.types.int;
      #   default = 4;
      # };
    };
  };
  config =
    let
      cfg = config.services.spark;
    in
    lib.mkIf cfg.enable {
      settings.processes.spark = {
        command = "${cfg.package}/bin/start-all.sh";
        is_daemon = true;
        shutdown.command = "${cfg.package}/bin/stop-all.sh";
        environment = [
          "SPARK_LOG_DIR=${cfg.logDir}"
        ];
      };
    };
}
