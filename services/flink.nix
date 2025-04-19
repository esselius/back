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
      settings.processes.flink-jobmanager = {
        command = "${cfg.package}/opt/flink/bin/jobmanager.sh start-foreground";
        environment = {
          JAVA_HOME = toString pkgs.jdk8.home;
        };
      };
      settings.processes.flink-taskmanager = {
        command = "${cfg.package}/opt/flink/bin/taskmanager.sh start-foreground";
        environment = {
          JAVA_HOME = toString pkgs.jdk8.home;
        };
      };
    };
}
