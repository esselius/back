{ config, lib, pkgs, name, ... }:

{
  options = {
    package = lib.mkPackageOption pkgs "zeppelin" { };
    confDir = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeTextDir "log4j.properties" config.log4jProperties;
    };
    logDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.dataDir}/logs";
    };
    pidDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.dataDir}/run";
    };
    notebookDir = lib.mkOption {
      type = lib.types.str;
      default = "$${PWD}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "$${PWD}/${config.dataDir}/conf";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8087;
    };
    useFlink = lib.mkEnableOption "Enable flink support";
    flinkPkg = lib.mkPackageOption pkgs "flink_1_17" { };
    useSpark = lib.mkEnableOption "Enable spark support";
    sparkPkg = lib.mkPackageOption pkgs "spark_3_5" { };

    log4jProperties = lib.mkOption {
      type = lib.types.str;
      default = ''
        log4j.rootLogger = INFO, stdout

        log4j.appender.stdout = org.apache.log4j.ConsoleAppender
        log4j.appender.stdout.layout = org.apache.log4j.PatternLayout
        log4j.appender.stdout.layout.ConversionPattern=%5p [%d] ({%t} %F[%M]:%L) - %m%n
      '';
    };
  };
  config = {
    outputs.settings.processes.${name} = {
      command = "${config.package}/bin/zeppelin.sh";
      environment = [
        "ZEPPELIN_LOG_DIR=${config.logDir}"
        "ZEPPELIN_PID_DIR=${config.pidDir}"
        "ZEPPELIN_NOTEBOOK_DIR=$${PWD}"
        "ZEPPELIN_CONF_DIR=${config.confDir}"
        "ZEPPELIN_CONFIG_FS_DIR=$${PWD}/${config.dataDir}/conf"
        "ZEPPELIN_WAR_TEMPDIR=$${PWD}/${config.dataDir}/tmp"
        "ZEPPELIN_PORT=${toString config.port}"
        "USE_HADOOP=false"
        "ZEPPELIN_SEARCH_INDEX_PATH=$${PWD}/${config.dataDir}/index"
      ] ++ lib.optional config.useFlink "FLINK_HOME=${config.flinkPkg}/opt/flink"
      ++ lib.optional config.useSpark "SPARK_HOME=${config.sparkPkg}";
    };
  };
}
