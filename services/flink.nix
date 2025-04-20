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
        };
      };
      "${name}-taskmanager" = {
        command = "${config.package}/opt/flink/bin/taskmanager.sh start-foreground";
        environment = {
          JAVA_HOME = toString pkgs.jdk8.home;
        };
      };
    };
  };
}
