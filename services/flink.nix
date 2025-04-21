{ config, lib, pkgs, name, ... }:
{
  options = {
    package = lib.mkPackageOption pkgs "flink_1_17" { };
  };
  config = {
    outputs.settings.processes = {
      "${name}-jobmanager" = {
        command = "${config.package}/opt/flink/bin/jobmanager.sh start-foreground";
        environment = {
          JAVA_HOME = toString pkgs.jdk8.home;
          FLINK_PID_DIR = "${config.dataDir}/run";
          FLINK_LOG_DIR = "${config.dataDir}/logs";
          FLINK_LOG_MAX = "0";
        };
      };
      "${name}-taskmanager" = {
        command = "${config.package}/opt/flink/bin/taskmanager.sh start-foreground";
        environment = {
          JAVA_HOME = toString pkgs.jdk8.home;
          FLINK_PID_DIR = "${config.dataDir}/run";
          FLINK_LOG_DIR = "${config.dataDir}/logs";
          FLINK_LOG_MAX = "0";
        };
      };
    };
  };
}
